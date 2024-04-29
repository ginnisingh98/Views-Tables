--------------------------------------------------------
--  DDL for Package Body CSD_HVR_BI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_HVR_BI_PVT" AS
/* $Header: csdvhbib.pls 120.1 2005/08/23 17:26:03 vkjain noship $ */

/*--------------------------------------------------*/
/* procedure name: get_last_run_date                */
/* description   : procedure used to get            */
/*                 the last run date for the ETL    */
/*--------------------------------------------------*/
  FUNCTION get_last_run_date(p_fact_name VARCHAR2) RETURN DATE IS
    l_last_run_date DATE;

  BEGIN

    SELECT last_run_date
      INTO l_last_run_date
      FROM csd_fact_details
     WHERE fact_name = p_fact_name;

    RETURN l_last_run_date;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
        -- 'Please launch the Initial Refresh for the High Volume Repair business data analysis process.'
      FND_MESSAGE.SET_NAME('CSD','CSD_HVR_BI_RUN_INITIAL_LOAD');
      FND_MSG_PUB.ADD;
       RAISE;

  END get_last_run_date;

/*--------------------------------------------------*/
/* procedure name: Refresh_Mviews                   */
/* description   : procedure to refresh all related */
/*                 mviews                           */
/*--------------------------------------------------*/
    PROCEDURE Refresh_Mviews (p_method IN varchar2) IS

    BEGIN

       -- refresh the mviews for the HVR Execution that
       -- are required for "Most Common Materials/Resources"
       DBMS_MVIEW.refresh(list => 'CSD_RO_PER_ITEM_MV',
                          method => p_method
                          -- method => '?'
                          -- rollback_seg         := NULL,
                          -- push_deferred_rpc    := TRUE,
                          -- refresh_after_errors := FALSE,
                          -- purge_option         := 1,
                          -- parallelism          := 0,
                          -- heap_size            := 0,
                          -- atomic_refresh       := TRUE
                         );

       DBMS_MVIEW.refresh(list => 'CSD_WIP_MTL_USED_MV',
                          method => p_method
                          -- method => '?'
                          -- rollback_seg         := NULL,
                          -- push_deferred_rpc    := TRUE,
                          -- refresh_after_errors := FALSE,
                          -- purge_option         := 1,
                          -- parallelism          := 0,
                          -- heap_size            := 0,
                          -- atomic_refresh       := TRUE
                         );

       dBMS_MVIEW.refresh(list => 'CSD_WIP_RES_USED_MV',
                          method => p_method
                          -- method => '?'
                          -- rollback_seg         := NULL,
                          -- push_deferred_rpc    := TRUE,
                          -- refresh_after_errors := FALSE,
                          -- purge_option         := 1,
                          -- parallelism          := 0,
                          -- heap_size            := 0,
                          -- atomic_refresh       := TRUE
                         );

       -- Refresh the mviews for the HVR SC,DC
       -- recommendations;required for "Frequency"
       -- The following mviews refresh is dependent
       -- on the refresh above (CSD_RO_PER_ITEM_MV)
       -- DO NOT reorder the refresh sequence.
       DBMS_MVIEW.refresh(list => 'CSD_DC_FREQ_SUM_MV',
                          method => p_method
                          -- method => '?'
                          -- rollback_seg         := NULL,
                          -- push_deferred_rpc    := TRUE,
                          -- refresh_after_errors := FALSE,
                          -- purge_option         := 1,
                          -- parallelism          := 0,
                          -- heap_size            := 0,
                          -- atomic_refresh       := TRUE
                         );

       DBMS_MVIEW.refresh(list => 'CSD_SC_FREQ_SUM_MV',
                          method => p_method
                          -- method => '?'
                          -- rollback_seg         := NULL,
                          -- push_deferred_rpc    := TRUE,
                          -- refresh_after_errors := FALSE,
                          -- purge_option         := 1,
                          -- parallelism          := 0,
                          -- heap_size            := 0,
                          -- atomic_refresh       := TRUE
                         );

    END Refresh_Mviews;

/*--------------------------------------------------*/
/* procedure name: Initial_Load_Ro_ETL              */
/* description   : procedure to load Repair Orders  */
/*                 fact initially.                  */
/*--------------------------------------------------*/
  PROCEDURE Initial_Load_Ro_ETL(errbuf  IN OUT NOCOPY VARCHAR2,
                                retcode IN OUT NOCOPY VARCHAR2)

   IS

    -- Variables --
    l_run_date               DATE;
    l_user_id                NUMBER;
    l_login_id               NUMBER;
    l_program_id             NUMBER;
    l_program_login_id       NUMBER;
    l_program_application_id NUMBER;
    l_request_id             NUMBER;

    -- Constants --
    lc_proc_name    CONSTANT VARCHAR2(30) := 'Initial_Load_Ro_ETL';

  BEGIN
    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID, -1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID, -1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID, -1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID, -1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Entering the initial refresh process for Repair Orders fact ...');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Deleting record from CSD_FACT_DETAILS for CSD_REPAIR_ORDERS_F name ...');

    DELETE FROM CSD_FACT_DETAILS where fact_name = C_CSD_REPAIR_ORDERS_F;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Delete successful.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Truncating table CSD_REPAIR_ORDERS_F ...');

    EXECUTE IMMEDIATE ('TRUNCATE TABLE CSD.CSD_REPAIR_ORDERS_F');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Truncate successful.');

    l_run_date := sysdate - 5 / (24 * 60);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Inserting into CSD_REPAIR_ORDERS_F ...');

    INSERT INTO CSD_REPAIR_ORDERS_F
      (repair_line_id,
       inventory_item_id,
       primary_quantity,
       primary_uom_code,
       ro_creation_date,
       date_closed,
       Status,
       created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_id,
       program_login_id,
       program_application_id,
       request_id)
      SELECT RO.repair_line_id,
             RO.inventory_item_id,
             (RO.quantity * UOM.conversion_rate) primary_quantity,
             UOM.primary_uom_code primary_uom_code,
             RO.creation_date,
             RO.date_closed,
             RO.status,
             l_user_id,
             sysdate,
             sysdate,
             l_user_id,
             l_login_id,
             l_program_id,
             l_program_login_id,
             l_program_application_id,
             l_request_id
        FROM CSD_REPAIRS RO, mtl_uom_conversions_view UOM
       WHERE RO.status = 'C'
         AND RO.repair_mode = 'WIP'
         AND UOM.inventory_item_id = RO.inventory_item_id
         AND UOM.organization_id = RO.inventory_org_id
         AND UOM.uom_code = RO.unit_of_measure;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Insert successful.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Inserting a record into CSD_FACT_DETAILS ...');

    INSERT INTO CSD_FACT_DETAILS
      (fact_name,
       last_run_date,
       created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_id,
       program_login_id,
       program_application_id,
       request_id)
    VALUES
      (C_CSD_REPAIR_ORDERS_F,
       l_run_date,
       l_user_id,
       sysdate,
       sysdate,
       l_user_id,
       l_login_id,
       l_program_id,
       l_program_login_id,
       l_program_application_id,
       l_request_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Insert successful.');

    commit;
    retcode := C_OK;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Leaving the initial refresh process for Repair Orders fact ...');

  EXCEPTION

    WHEN OTHERS THEN
      retcode := C_ERROR;
      FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Unknown exception. SQLERRM = ' || SQLERRM);
      ROLLBACK;
      RAISE;

  END Initial_Load_Ro_ETL;

/*--------------------------------------------------*/
/* procedure name: Incr_Load_Ro_ETL                 */
/* description   : procedure to load Repair Orders  */
/*                 fact incrementally               */
/*--------------------------------------------------*/
  PROCEDURE Incr_Load_Ro_ETL(errbuf  in out NOCOPY VARCHAR2,
                             retcode IN OUT NOCOPY VARCHAR2)

   IS

    -- Variables --
    l_run_date               DATE;
    l_last_run_date          DATE;
    l_user_id                NUMBER;
    l_login_id               NUMBER;
    l_program_id             NUMBER;
    l_program_login_id       NUMBER;
    l_program_application_id NUMBER;
    l_request_id             NUMBER;

    -- Constants --
    lc_proc_name    CONSTANT VARCHAR2(30) := 'Incr_Load_Ro_ETL';

  BEGIN

    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID, -1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID, -1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID, -1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID, -1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Entering the incremental refresh process for Repair Orders fact ...');

    l_last_run_date := get_last_run_date(C_CSD_REPAIR_ORDERS_F);

    l_run_date := sysdate - 5 / (24 * 60);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Merging data into CSD_REPAIR_ORDERS_F ...');

    MERGE INTO CSD_REPAIR_ORDERS_F fact
    USING (SELECT RO.repair_line_id,
                  RO.inventory_item_id,
                  (RO.quantity * UOM.conversion_rate) primary_quantity,
                  UOM.primary_uom_code primary_uom_code,
                  RO.creation_date,
                  RO.date_closed,
                  RO.status
             FROM CSD_REPAIRS RO,
                  mtl_uom_conversions_view UOM
            WHERE
            -- RO.status = 'C' AND
            RO.repair_mode = 'WIP'
        AND UOM.inventory_item_id = RO.inventory_item_id
        AND UOM.organization_id = RO.inventory_org_id
        AND UOM.uom_code = RO.unit_of_measure
        AND RO.last_update_date > l_last_run_date) OLTP
    ON (fact.repair_line_id = OLTP.repair_line_id)
    WHEN MATCHED THEN
      UPDATE
         SET fact.inventory_item_id      = OLTP.inventory_item_id,
             fact.primary_quantity       = OLTP.primary_quantity,
             fact.primary_uom_code       = OLTP.primary_uom_code,
             fact.date_closed            = OLTP.date_closed,
             fact.status                 = OLTP.status,
             fact.last_update_date       = sysdate,
             fact.last_updated_by        = l_user_id,
             fact.last_update_login      = l_login_id,
             fact.program_id             = l_program_id,
             fact.program_login_id       = l_program_login_id,
             fact.program_application_id = l_program_application_id,
             fact.request_id             = l_request_id
    WHEN NOT MATCHED THEN
      INSERT
      VALUES
        (OLTP.repair_line_id,
         OLTP.inventory_item_id,
         OLTP.primary_quantity,
         OLTP.primary_uom_code,
         OLTP.creation_date,
         OLTP.date_closed,
         OLTP.status,
         l_user_id,
         sysdate,
         sysdate,
         l_user_id,
         l_login_id,
         l_program_id,
         l_program_login_id,
         l_program_application_id,
         l_request_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Merge complete.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Updating CSD_FACT_DETAILS ...');

    UPDATE CSD_FACT_DETAILS
       SET last_run_date          = l_run_date,
           last_update_date       = sysdate,
           last_updated_by        = l_user_id,
           last_update_login      = l_login_id,
           program_id             = l_program_id,
           program_login_id       = l_program_login_id,
           program_application_id = l_program_application_id,
           request_id             = l_request_id
     WHERE fact_name = C_CSD_REPAIR_ORDERS_F;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Update complete.');

    commit;
    retcode := C_OK;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Leaving the incremental refresh process for Repair Orders fact ...');

  EXCEPTION

    WHEN OTHERS THEN

      retcode := C_ERROR;
      FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Unknown exception. SQLERRM = ' || SQLERRM);
      ROLLBACK;
      RAISE;

  END Incr_Load_Ro_ETL;

/*--------------------------------------------------*/
/* procedure name: Initial_Load_Mtl_ETL             */
/* description   : procedure to load Materials      */
/*                 Consumed fact initially.         */
/*--------------------------------------------------*/

  PROCEDURE Initial_Load_Mtl_ETL(errbuf  IN OUT NOCOPY VARCHAR2,
                                 retcode IN OUT NOCOPY VARCHAR2)

   IS

    -- Variables --
    l_run_date               DATE;
    l_user_id                NUMBER;
    l_login_id               NUMBER;
    l_program_id             NUMBER;
    l_program_login_id       NUMBER;
    l_program_application_id NUMBER;
    l_request_id             NUMBER;

    -- Constants --
    lc_proc_name    CONSTANT VARCHAR2(30) := 'Initial_Load_Mtl_ETL';

  BEGIN
    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID, -1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID, -1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID, -1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID, -1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Entering the initial refresh process for Materials Consumed fact ...');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Deleting record from CSD_FACT_DETAILS for CSD_MTL_CONSUMED_F name ...');

    DELETE FROM CSD_FACT_DETAILS where fact_name = C_CSD_MTL_CONSUMED_F;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Delete successful.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Truncating table CSD_MTL_CONSUMED_F ...');

    EXECUTE IMMEDIATE ('TRUNCATE TABLE CSD.CSD_MTL_CONSUMED_F');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Truncate successful.');

    l_run_date := sysdate - 5 / (24 * 60);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Inserting into CSD_MTL_CONSUMED_F ...');

    INSERT INTO CSD_MTL_CONSUMED_F
      (repair_line_id,
       inventory_item_id,
       primary_quantity,
       primary_uom_code,
       created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_id,
       program_login_id,
       program_application_id,
       request_id)
      SELECT RO.repair_line_id,
             mmt.inventory_item_id INVENTORY_ITEM_ID,
             SUM(DECODE(MMT.transaction_type_id,
                             lc_MTL_TXN_TYPE_COMP_ISSUE,
                             ABS(mmt.primary_quantity),
                             lc_MTL_TXN_TYPE_COMP_RETURN,
                             (-1 * ABS(mmt.primary_quantity)))) QUANTITY,
             MSI.primary_uom_code UOM,
             l_user_id,
             sysdate,
             sysdate,
             l_user_id,
             l_login_id,
             l_program_id,
             l_program_login_id,
             l_program_application_id,
             l_request_id
        FROM CSD_REPAIR_ORDERS_F       RO,
             CSD_REPAIR_JOB_XREF       XREF,
             WIP_DISCRETE_JOBS         DJOB,
             MTL_MATERIAL_TRANSACTIONS MMT,
             MTL_SYSTEM_ITEMS_B        MSI
       WHERE RO.status = 'C'
         AND XREF.repair_line_id = RO.repair_line_id
         AND XREF.inventory_item_id = RO.inventory_item_id
         AND DJOB.wip_entity_id = XREF.wip_entity_id
         AND DJOB.status_type in (4, 5, 12)
         AND MMT.transaction_source_id = DJOB.wip_entity_id
         AND MMT.transaction_source_type_id = 5 -- 'WIP'
         AND (MMT.transaction_type_id = lc_MTL_TXN_TYPE_COMP_ISSUE
              OR
              MMT.transaction_type_id = lc_MTL_TXN_TYPE_COMP_RETURN)
         AND MMT.inventory_item_id <> RO.inventory_item_id
         AND MSI.inventory_item_id = MMT.inventory_item_id
         AND MSI.organization_id = XREF.organization_id
       GROUP BY RO.repair_line_id,
                MMT.inventory_item_id,
                MSI.primary_uom_code;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Insert successful.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Inserting a record into CSD_FACT_DETAILS ...');

    INSERT INTO CSD_FACT_DETAILS
      (fact_name,
       last_run_date,
       created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_id,
       program_login_id,
       program_application_id,
       request_id)
    VALUES
      (C_CSD_MTL_CONSUMED_F,
       l_run_date,
       l_user_id,
       sysdate,
       sysdate,
       l_user_id,
       l_login_id,
       l_program_id,
       l_program_login_id,
       l_program_application_id,
       l_request_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Insert successful.');

    commit;
    retcode := C_OK;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Leaving the initial refresh process for Materials Consumed fact ...');

  EXCEPTION

    WHEN OTHERS THEN
      retcode := C_ERROR;
      FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Unknown exception. SQLERRM = ' || SQLERRM);
      ROLLBACK;
      RAISE;

  END Initial_Load_Mtl_ETL;

/*--------------------------------------------------*/
/* procedure name: Incr_Load_Mtl_ETL                */
/* description   : procedure to load Materials      */
/*                 Consumed fact incrementally      */
/*--------------------------------------------------*/
  PROCEDURE Incr_Load_Mtl_ETL(errbuf  in out NOCOPY VARCHAR2,
                              retcode IN OUT NOCOPY VARCHAR2)

   IS

    -- Variables --
    l_run_date               DATE;
    l_last_run_date          DATE;
    l_user_id                NUMBER;
    l_login_id               NUMBER;
    l_program_id             NUMBER;
    l_program_login_id       NUMBER;
    l_program_application_id NUMBER;
    l_request_id             NUMBER;

    -- Constants --
    lc_proc_name    CONSTANT VARCHAR2(30) := 'Incr_Load_Mtl_ETL';

  BEGIN

    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID, -1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID, -1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID, -1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID, -1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Entering the incremental refresh process for Materials Consumed fact ...');

    l_last_run_date := get_last_run_date(C_CSD_MTL_CONSUMED_F);

    l_run_date := sysdate - 5 / (24 * 60);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Merging data into CSD_MTL_CONSUMED_F ...');

      MERGE INTO CSD_MTL_CONSUMED_F fact
      USING (SELECT RO.repair_line_id,
                    mmt.inventory_item_id INVENTORY_ITEM_ID,
                    CEIL(SUM(DECODE(MMT.transaction_type_id,
                                    lc_MTL_TXN_TYPE_COMP_ISSUE,
                                    ABS(mmt.primary_quantity),
                                    lc_MTL_TXN_TYPE_COMP_RETURN,
                                    (-1 * ABS(mmt.primary_quantity))))) PRIMARY_QUANTITY,
                    MSI.primary_uom_code PRIMARY_UOM_CODE
               FROM CSD_REPAIR_ORDERS_F       RO,
                    CSD_REPAIR_JOB_XREF       XREF,
                    WIP_DISCRETE_JOBS         DJOB,
                    MTL_MATERIAL_TRANSACTIONS MMT,
                    MTL_SYSTEM_ITEMS_B        MSI
              WHERE RO.status = 'C'
                AND XREF.repair_line_id = RO.repair_line_id
                AND XREF.inventory_item_id = RO.inventory_item_id
                AND DJOB.wip_entity_id = XREF.wip_entity_id
                AND DJOB.status_type in (4, 5, 12)
                AND MMT.transaction_source_id = DJOB.wip_entity_id
                AND MMT.transaction_source_type_id = 5 -- 'WIP'
                AND (MMT.transaction_type_id = lc_MTL_TXN_TYPE_COMP_ISSUE
                     OR
                     MMT.transaction_type_id = lc_MTL_TXN_TYPE_COMP_RETURN)
                AND MMT.inventory_item_id <> RO.inventory_item_id
                AND MSI.inventory_item_id = MMT.inventory_item_id
                AND MSI.organization_id = XREF.organization_id
                AND RO.last_update_date > l_last_run_date
              GROUP BY RO.repair_line_id,
                       MMT.inventory_item_id,
                       MSI.primary_uom_code) OLTP
      ON (fact.repair_line_id = OLTP.repair_line_id AND fact.inventory_item_id = OLTP.inventory_item_id)
      WHEN MATCHED THEN
        UPDATE
           SET fact.primary_quantity       = OLTP.primary_quantity,
               fact.primary_uom_code       = OLTP.primary_uom_code,
               fact.last_update_date       = sysdate,
               fact.last_updated_by        = l_user_id,
               fact.last_update_login      = l_login_id,
               fact.program_id             = l_program_id,
               fact.program_login_id       = l_program_login_id,
               fact.program_application_id = l_program_application_id,
               fact.request_id             = l_request_id
      WHEN NOT MATCHED THEN
        INSERT
        VALUES
          (OLTP.repair_line_id,
           OLTP.inventory_item_id,
           OLTP.primary_quantity,
           OLTP.primary_uom_code,
           l_user_id,
           sysdate,
           sysdate,
           l_user_id,
           l_login_id,
           l_program_id,
           l_program_login_id,
           l_program_application_id,
           l_request_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Merge complete.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Updating CSD_FACT_DETAILS ...');

    UPDATE CSD_FACT_DETAILS
       SET last_run_date          = l_run_date,
           last_update_date       = sysdate,
           last_updated_by        = l_user_id,
           last_update_login      = l_login_id,
           program_id             = l_program_id,
           program_login_id       = l_program_login_id,
           program_application_id = l_program_application_id,
           request_id             = l_request_id
     WHERE fact_name = C_CSD_MTL_CONSUMED_F;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Update complete.');

    commit;
    retcode := C_OK;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Leaving the incremental refresh process for Materials Consumed fact ...');

  EXCEPTION

    WHEN OTHERS THEN

      retcode := C_ERROR;
      FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Unknown exception. SQLERRM = ' || SQLERRM);
      ROLLBACK;
      RAISE;

  END Incr_Load_Mtl_ETL;

/*--------------------------------------------------*/
/* procedure name: Initial_Load_Res_ETL             */
/* description   : procedure to load Resources      */
/*                 Consumed fact initially.         */
/*--------------------------------------------------*/

  PROCEDURE Initial_Load_Res_ETL(errbuf  IN OUT NOCOPY VARCHAR2,
                                 retcode IN OUT NOCOPY VARCHAR2)

   IS

    -- Variables --
    l_run_date               DATE;
    l_user_id                NUMBER;
    l_login_id               NUMBER;
    l_program_id             NUMBER;
    l_program_login_id       NUMBER;
    l_program_application_id NUMBER;
    l_request_id             NUMBER;

    -- Constants --
    lc_proc_name    CONSTANT VARCHAR2(30) := 'Initial_Load_Res_ETL';

  BEGIN
    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID, -1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID, -1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID, -1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID, -1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Entering the initial refresh process for Resources Consumed fact ...');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Deleting record from CSD_FACT_DETAILS for CSD_RES_CONSUMED_F name ...');

    DELETE FROM CSD_FACT_DETAILS where fact_name = C_CSD_RES_CONSUMED_F;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Delete successful.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Truncating table CSD_RES_CONSUMED_F ...');

    EXECUTE IMMEDIATE ('TRUNCATE TABLE CSD.CSD_RES_CONSUMED_F');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Truncate successful.');

    l_run_date := sysdate - 5 / (24 * 60);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Inserting into CSD_RES_CONSUMED_F ...');

    INSERT INTO CSD_RES_CONSUMED_F
      (repair_line_id,
       resource_id,
       primary_quantity,
       primary_uom_code,
       created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_id,
       program_login_id,
       program_application_id,
       request_id)
      SELECT RO.repair_line_id,
             WTXN.resource_id resource_id,
             SUM(NVL(WTXN.primary_quantity, 0)) primary_quantity,
             WTXN.primary_uom primary_uom_code,
             l_user_id,
             sysdate,
             sysdate,
             l_user_id,
             l_login_id,
             l_program_id,
             l_program_login_id,
             l_program_application_id,
             l_request_id
        FROM CSD_REPAIR_ORDERS_F RO,
             CSD_REPAIR_JOB_XREF XREF,
             WIP_DISCRETE_JOBS   DJOB,
             WIP_TRANSACTIONS    WTXN
       WHERE RO.status = 'C'
         AND XREF.repair_line_id = RO.repair_line_id
         AND XREF.inventory_item_id = RO.inventory_item_id
         AND DJOB.wip_entity_id = XREF.wip_entity_id
         AND DJOB.status_type in (4, 5, 12)
         AND WTXN.wip_entity_id = DJOB.wip_entity_id
         AND WTXN.transaction_type IN (1, 2, 3)
         AND WTXN.resource_id IS NOT NULL
       GROUP BY RO.repair_line_id, WTXN.primary_uom, WTXN.resource_id;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Insert successful.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Inserting a record into CSD_FACT_DETAILS ...');

    INSERT INTO CSD_FACT_DETAILS
      (fact_name,
       last_run_date,
       created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_id,
       program_login_id,
       program_application_id,
       request_id)
    VALUES
      (C_CSD_RES_CONSUMED_F,
       l_run_date,
       l_user_id,
       sysdate,
       sysdate,
       l_user_id,
       l_login_id,
       l_program_id,
       l_program_login_id,
       l_program_application_id,
       l_request_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Insert successful.');

    commit;
    retcode := C_OK;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Leaving the initial refresh process for Resources Consumed fact ...');

  EXCEPTION

    WHEN OTHERS THEN
      retcode := C_ERROR;
      FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Unknown exception. SQLERRM = ' || SQLERRM);
      ROLLBACK;
      RAISE;

  END Initial_Load_Res_ETL;

/*--------------------------------------------------*/
/* procedure name: Incr_Load_Res_ETL                */
/* description   : procedure to load Resources      */
/*                 Consumed fact incrementally      */
/*--------------------------------------------------*/
  PROCEDURE Incr_Load_Res_ETL(errbuf  in out NOCOPY VARCHAR2,
                              retcode IN OUT NOCOPY VARCHAR2)

   IS

    -- Variables --
    l_run_date               DATE;
    l_last_run_date          DATE;
    l_user_id                NUMBER;
    l_login_id               NUMBER;
    l_program_id             NUMBER;
    l_program_login_id       NUMBER;
    l_program_application_id NUMBER;
    l_request_id             NUMBER;

    -- Constants --
    lc_proc_name    CONSTANT VARCHAR2(30) := 'Incr_Load_Res_ETL';

  BEGIN

    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID, -1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID, -1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID, -1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID, -1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Entering the incremental refresh process for Resources Consumed fact ...');

    l_last_run_date := get_last_run_date(C_CSD_RES_CONSUMED_F);

    l_run_date := sysdate - 5 / (24 * 60);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Merging data into CSD_RES_CONSUMED_F ...');

    MERGE INTO CSD_RES_CONSUMED_F fact
    USING (SELECT RO.repair_line_id,
                  WTXN.resource_id resource_id,
                  SUM(NVL(WTXN.primary_quantity, 0)) primary_quantity,
                  WTXN.primary_uom primary_uom_code
             FROM CSD_REPAIR_ORDERS_F RO,
                  CSD_REPAIR_JOB_XREF XREF,
                  WIP_DISCRETE_JOBS   DJOB,
                  WIP_TRANSACTIONS    WTXN
            WHERE RO.status = 'C'
              AND XREF.repair_line_id = RO.repair_line_id
              AND XREF.inventory_item_id = RO.inventory_item_id
              AND DJOB.wip_entity_id = XREF.wip_entity_id
              AND DJOB.status_type in (4, 5, 12)
              AND WTXN.wip_entity_id = DJOB.wip_entity_id
              AND WTXN.transaction_type IN (1, 2, 3)
              AND WTXN.resource_id IS NOT NULL
              AND RO.last_update_date > l_last_run_date
            GROUP BY RO.repair_line_id, WTXN.primary_uom, WTXN.resource_id) OLTP
    ON (fact.repair_line_id = OLTP.repair_line_id AND fact.resource_id = OLTP.resource_id)
    WHEN MATCHED THEN
      UPDATE
         SET fact.primary_quantity       = OLTP.primary_quantity,
             fact.primary_uom_code       = OLTP.primary_uom_code,
             fact.last_update_date       = sysdate,
             fact.last_updated_by        = l_user_id,
             fact.last_update_login      = l_login_id,
             fact.program_id             = l_program_id,
             fact.program_login_id       = l_program_login_id,
             fact.program_application_id = l_program_application_id,
             fact.request_id             = l_request_id
    WHEN NOT MATCHED THEN
      INSERT
      VALUES
        (OLTP.repair_line_id,
         OLTP.resource_id,
         OLTP.primary_quantity,
         OLTP.primary_uom_code,
         l_user_id,
         sysdate,
         sysdate,
         l_user_id,
         l_login_id,
         l_program_id,
         l_program_login_id,
         l_program_application_id,
         l_request_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Merge complete.');

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Updating CSD_FACT_DETAILS ...');

    UPDATE CSD_FACT_DETAILS
       SET last_run_date          = l_run_date,
           last_update_date       = sysdate,
           last_updated_by        = l_user_id,
           last_update_login      = l_login_id,
           program_id             = l_program_id,
           program_login_id       = l_program_login_id,
           program_application_id = l_program_application_id,
           request_id             = l_request_id
     WHERE fact_name = C_CSD_RES_CONSUMED_F;

    FND_FILE.PUT_LINE(FND_FILE.LOG,lc_proc_name || ': ' || 'Update complete.');

    commit;
    retcode := C_OK;

    FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Leaving the incremental refresh process for Resources Consumed fact ...');

  EXCEPTION

    WHEN OTHERS THEN

      retcode := C_ERROR;
      FND_FILE.PUT_LINE(FND_FILE.LOG, lc_proc_name || ': ' || 'Unknown exception. SQLERRM = ' || SQLERRM);
      ROLLBACK;
      RAISE;

  END Incr_Load_Res_ETL;

/*--------------------------------------------------*/
/* procedure name: Initial_Load                     */
/* description   : procedure to load Repair Orders  */
/*                 Resource and Material facts      */
/*                 initially.                       */
/*--------------------------------------------------*/
PROCEDURE Initial_Load(errbuf  IN OUT NOCOPY VARCHAR2,
                       retcode IN OUT NOCOPY varchar2)

 IS

  -- Variables --
  l_errbuf                 VARCHAR2(2000);
  l_retcode                VARCHAR2(1);

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Entering the initial refresh process  ...');

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Calling the initial refresh process for Repair Orders fact ...');

  -- Initializing to success.
  retcode := c_OK;

  CSD_HVR_BI_PVT.initial_load_Ro_etl(errbuf  => l_errbuf,
                                     retcode => l_retcode);

  if (l_retcode = c_OK) then
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Initial refresh process for Repair Orders fact completed succesfully...');
  else
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Initial refresh process for Repair Orders fact failed with following error: ' || l_errbuf);
    if (retcode < l_retcode) then
       retcode := l_retcode;
       errbuf := l_errbuf;
    end if;
  end if;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Calling the initial refresh process for Material Consumption fact ...');

  CSD_HVR_BI_PVT.initial_load_MTL_etl(errbuf  => l_errbuf,
                                      retcode => l_retcode);

  if (l_retcode = c_OK) then
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Initial refresh process for Material Consumption fact completed succesfully...');
  else
    if (retcode < l_retcode) then
       retcode := l_retcode;
       errbuf := l_errbuf;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Initial refresh process for Material Consumption fact failed with following error: ' || l_errbuf);
  end if;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Calling the initial refresh process for Resource fact ...');

  CSD_HVR_BI_PVT.initial_load_RES_etl(errbuf  => l_errbuf,
                                      retcode => l_retcode);

  if (l_retcode = c_OK) then
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Initial refresh process for resource fact completed succesfully...');
  else
    if (retcode < l_retcode) then
       retcode := l_retcode;
       errbuf := l_errbuf;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Initial refresh process for  Resource fact failed with following error: ' || l_errbuf);
  end if;

  -- commit;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Leaving the initial refresh process  ...');

EXCEPTION

  WHEN OTHERS THEN
    retcode := C_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Unknown exception. SQLERRM = ' || SQLERRM);
    ROLLBACK;
    RAISE;

END Initial_Load;

/*--------------------------------------------------*/
/* procedure name: Incr_load                        */
/* description   : procedure to load                */
/*                 fact  tables incrementally       */
/*--------------------------------------------------*/
PROCEDURE Incr_load(errbuf  in out NOCOPY VARCHAR2,
                    retcode in out NOCOPY VARCHAR2)

 IS

  -- Variables --
  l_errbuf                 VARCHAR2(2000);
  l_retcode                VARCHAR2(1);

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Entering the incremental refresh process  ...');

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Calling the incremental refresh process for Repair Orders fact ...');

  CSD_HVR_BI_PVT.Incr_load_Ro_etl(errbuf => l_errbuf,
                                  retcode => l_retcode);

  if (retcode = c_OK) then
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Incremental refresh process for Repair Orders fact completed succesfully...');
  else
    if (retcode < l_retcode) then
       retcode := l_retcode;
       errbuf := l_errbuf;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Incremental refresh process for Repair Orders fact failed with following error: ' || l_errbuf);
  end if;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Calling the incremental refresh process for Material Consumption fact ...');

  CSD_HVR_BI_PVT.Incr_load_MTL_etl(errbuf  => l_errbuf,
                                   retcode => l_retcode);

  if (retcode = c_OK) then
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Incremental refresh process for Material Consumption fact completed succesfully...');
  else
    if (retcode < l_retcode) then
       retcode := l_retcode;
       errbuf := l_errbuf;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Incremental refresh process for  Material Consumption fact failed with following error: ' || l_errbuf);
  end if;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Calling the incremental refresh process for Resource fact ...');

  CSD_HVR_BI_PVT.Incr_load_RES_etl(errbuf  => l_errbuf,
                                   retcode => l_retcode);

  if (retcode = c_OK) then
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Incremental refresh process for resource fact completed succesfully...');
  else
    if (retcode < l_retcode) then
       retcode := l_retcode;
       errbuf := l_errbuf;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Incremental refresh process for  Resource fact failed with following error: ' || l_errbuf);
  end if;

  -- commit;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Leaving the incremental refresh process  ...');

EXCEPTION

  WHEN OTHERS THEN
    retcode := C_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Unknown exception. SQLERRM = ' || SQLERRM);
    ROLLBACK;
    RAISE;

END Incr_load;

/*--------------------------------------------------*/
/* procedure name: Hvr_Bi_Driver_Main    */
/* description   : procedure to load            */
/*                 fact  tables incrementally       */
/*--------------------------------------------------*/
    PROCEDURE Hvr_Bi_Driver_Main(errbuf         IN OUT NOCOPY VARCHAR2,
                                 retcode        IN OUT NOCOPY VARCHAR2,
                                 p_refresh_type IN VARCHAR2) IS

    l_refresh_method  VARCHAR2(3);

    BEGIN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Entering the concurrent program...');

      IF (p_refresh_type = 'INITIAL') then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling Initial_Load ...');
        initial_load(errbuf, retcode);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Returning from Initial_Load ...');
        l_refresh_method := 'C';
      else
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling Incr_Load ...');
        incr_load(errbuf, retcode);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Returning from Incr_Load ...');
        l_refresh_method := '?';
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling Refresh_Mviews...');
      Refresh_Mviews(p_method => l_refresh_method);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Returning from Refresh_Mviews...');

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Leaving the concurrent program...');

    EXCEPTION

      WHEN OTHERS THEN
        retcode := C_ERROR;
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'Unknown exception. SQLERRM = ' || SQLERRM);
        ROLLBACK;
        RAISE;

    END Hvr_Bi_Driver_Main;

END CSD_HVR_BI_PVT;

/
