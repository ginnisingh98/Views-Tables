--------------------------------------------------------
--  DDL for Package Body CSD_MIGRATE_FROM_115X_PKG6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MIGRATE_FROM_115X_PKG6" 
/* $Header: csdmig6b.pls 120.6 2005/09/23 12:27:37 sangigup noship $ */
AS

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_TASKS_MIG6                                                 */
/* description   : procedure for migrating Task data                             */
/*                 from 11.5.10 to R12                                           */
/* purpose      :  Create Repair Task record in CSD_TASKS                        */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_task_mig6(p_slab_number IN NUMBER DEFAULT 1)
        IS

        v_min                NUMBER;
        v_max                NUMBER;
        v_error_text         VARCHAR2(2000);
        MAX_BUFFER_SIZE      NUMBER                 := 500;
        l_repair_task_id   NUMBER;
        error_process         EXCEPTION;

        /*CURSOR get_repair_tasks(p_start_repair_line_id number, p_end_repair_line_id number)
        IS
	select jtf_tasks_vl.task_id, repair_line_id
	from jtf_tasks_vl, csd_repairs
	where jtf_tasks_vl.source_object_id = csd_repairs.repair_line_id
	and source_object_type_code='DR'
	and repair_line_id between p_start_repair_line_id
		 and p_end_repair_line_id
	and not exists( select 'x' from csd_tasks
                where csd_tasks.task_id = jtf_tasks_vl.task_id
                and csd_tasks.repair_line_id = csd_repairs.repair_line_id);*/

    BEGIN
        -- Get the Slab Number for the table

        BEGIN

            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIRS',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);

            IF v_min IS NULL
                THEN
                    RETURN;
            END IF;

        END;

        -- Migration code for creating Repair Tasks
	insert into CSD_TASKS (
            REPAIR_TASK_ID,
            TASK_ID,
	    REPAIR_LINE_ID,
	    APPLICABLE_QA_PLANS,
	    OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
          ) select
            CSD.csd_tasks_s.nextval,
            jtf_tasks_vl.task_id,
            csd_repairs.repair_line_id,
	    'N',
	    1,
	    FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.login_id
          from jtf_tasks_vl,
               CSD_REPAIRS
	   where jtf_tasks_vl.source_object_id = csd_repairs.repair_line_id
		and source_object_type_code='DR'
		and repair_line_id between v_min and v_max
		and not exists( select 'x' from csd_tasks
                where csd_tasks.task_id = jtf_tasks_vl.task_id
                and csd_tasks.repair_line_id = csd_repairs.repair_line_id);


            COMMIT;

    END csd_task_mig6;


/*-----------------------------------------------------------------------------*/
/* procedure name: csd_flex_flow_mig6                                          */
/* description   : Migration script for 12.0 Flex Flow specific changes.       */
/*-----------------------------------------------------------------------------*/

    PROCEDURE csd_flex_flow_mig6

    IS

    -- Definitions --
    TYPE VARTAB IS TABLE OF VARCHAR2(1);
    TYPE NUMTAB IS TABLE OF NUMBER;
    TYPE REP_LINE_ID_ARRAY_TYPE IS VARRAY (1000)
         OF CSD.CSD_REPAIRS.REPAIR_LINE_ID%TYPE;
    TYPE ORIG_SOURCE_REF_ARRAY_TYPE IS VARRAY (1000)
         OF CSD.CSD_REPAIRS.ORIGINAL_SOURCE_REFERENCE%TYPE;
    TYPE FLOW_STATUS_ID_ARRAY_TYPE IS VARRAY (1000)
         OF CSD.CSD_REPAIRS.FLOW_STATUS_ID%TYPE;
    TYPE INVENTORY_ORG_ID_ARRAY_TYPE IS VARRAY (1000)
         OF CSD.CSD_REPAIRS.INVENTORY_ORG_ID%TYPE;
    TYPE INVENTORY_ITEM_ID_ARRAY_TYPE IS VARRAY (1000)
         OF CSD.CSD_REPAIRS.INVENTORY_ITEM_ID%TYPE;

    -- Variables --
    repair_line_id_arr             REP_LINE_ID_ARRAY_TYPE;
    original_source_reference_arr  ORIG_SOURCE_REF_ARRAY_TYPE;
    flow_status_id_arr             FLOW_STATUS_ID_ARRAY_TYPE;
    inventory_org_id_arr           INVENTORY_ORG_ID_ARRAY_TYPE;
    inventory_item_id_arr          INVENTORY_ITEM_ID_ARRAY_TYPE;
    l_inv_org_id                   NUMBER;

    -- Do not mess with the order of values below.
    -- It is crucial for the logic further below.
    FlowStatusCodes VARTAB := VARTAB('C', 'H', 'O', 'D');
    FlowStatusIDs NUMTAB := NUMTAB(-1, -1, -1, -1);

    -- Constants --
    c_closed_index CONSTANT NUMBER := 1;
    c_hold_index CONSTANT   NUMBER := 2;
    c_open_index CONSTANT   NUMBER := 3;
    c_draft_index CONSTANT  NUMBER := 4;
    MAX_BUFFER_SIZE         NUMBER := 1000;

    -- EXCEPTIONS --
    UNIQUE_CONSTRAINT_VIOLATED Exception;

    -- This will trap all exceptions that have
    -- SQLCODE = -00001 and name it as 'UNIQUE_CONSTRAINT_VIOLATED'.
    PRAGMA EXCEPTION_INIT( UNIQUE_CONSTRAINT_VIOLATED, -00001 );


    -- Cursor to derive the eligible repair orders
    Cursor c_get_upd_ro_cursor is
    Select
      repair_line_id,
      original_source_reference,
      flow_status_id,
      inventory_org_id,
      inventory_item_id
    from csd_repairs
    where flow_status_id is null
    or inventory_org_id is null;

    -- Cursor to get om rma org id
    CURSOR c_get_om_rma_org_id (p_repair_line_id in number) IS
    SELECT oel.ship_from_org_id
    FROM oe_order_lines_all oel,
         csd_repairs cr
    WHERE
         cr.repair_line_id = p_repair_line_id
    AND  cr.original_source_header_id = oel.header_id
    AND  cr.original_source_line_id = oel.line_id;

    -- Cursor to get ro rma org id
    CURSOR c_get_ro_rma_org_id (p_repair_line_id in number) IS
    SELECT oel.ship_from_org_Id
    FROM oe_order_lines_all oel,
         csd_product_transactions cp
    WHERE cp.repair_line_id = p_repair_line_Id
    AND   cp.action_type in ('RMA','MOVE_IN')
    AND   cp.order_line_id = oel.line_id
    AND   cp.order_header_id = oel.header_id;

    -- Cursor to get item org id
    CURSOR c_get_item_org_id (p_inventory_item_id in number) IS
    SELECT organization_id
    FROM mtl_system_items_kfv
    WHERE inventory_item_id = p_inventory_item_id;

    BEGIN

       -- STEP 1: Insert records to populate the flow statuses definitions

       FOR i IN FlowStatusCodes.FIRST..FlowStatusCodes.LAST LOOP

            BEGIN
               insert into CSD_FLOW_STATUSES_B (
                                FLOW_STATUS_ID,
                                FLOW_STATUS_CODE,
                                STATUS_CODE,
                                SEEDED_FLAG,
                                OBJECT_VERSION_NUMBER,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN
                              ) values (
                                CSD_FLOW_STATUSES_S1.nextval,
                                FlowStatusCodes(i),
                                FlowStatusCodes(i), -- literal value is same
                                'Y',
                                1,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                FND_GLOBAL.LOGIN_ID
                              );

            EXCEPTION
               WHEN UNIQUE_CONSTRAINT_VIOLATED THEN
                  -- Do nothing, as the record already exists
                  NULL;
            END;

       END LOOP;

          insert into CSD_FLOW_STATUSES_TL (
            FLOW_STATUS_ID,
            EXTERNAL_DISPLAY_STATUS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            LANGUAGE,
            SOURCE_LANG
          ) select
            FS_B.flow_status_id,
            NULL, -- EXTERNAL_DISPLAY_STATUS
            FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.login_id,
            L.LANGUAGE_CODE,
            L.LANGUAGE_CODE
          from FND_LANGUAGES L,
               CSD_FLOW_STATUSES_B FS_B
          where L.INSTALLED_FLAG in ('I', 'B')
          AND   FS_B.flow_status_code in ('C','H','O','D')
          and not exists
            (select 'x'
            from CSD_FLOW_STATUSES_TL T
            where T.FLOW_STATUS_ID = FS_B.flow_status_id
            and T.LANGUAGE = L.LANGUAGE_CODE);

       -- STEP 2: Insert into the status transitions for each Repair Type.

      insert into CSD_FLWSTS_TRANS_B (
            REPAIR_TYPE_ID,
            FROM_FLOW_STATUS_ID,
            TO_FLOW_STATUS_ID,
            WF_ITEM_TYPE,
            WF_PROCESS_NAME,
            REASON_REQUIRED_FLAG,
            CAPTURE_ACTIVITY_FLAG,
            ALLOW_ALL_RESP_FLAG,
            OBJECT_VERSION_NUMBER,
            FLWSTS_TRAN_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
          )
            SELECT RT.repair_type_id,
                   FS_B1.flow_status_id,
                   FS_B2.flow_status_id,
                   NULL, -- P_WF_ITEM_TYPE
                   NULL, -- P_WF_PROCESS_NAME
                   'N', -- P_REASON_REQUIRED_FLAG,
                   'Y', -- P_CAPTURE_ACTIVITY_FLAG,
                   'Y', -- P_ALLOW_ALL_RESP_FLAG,
                   1,
                   CSD_FLWSTS_TRANS_S1.nextval,
                   SYSDATE,
                   FND_GLOBAL.user_id,
                   SYSDATE,
                   FND_GLOBAL.user_id,
                   FND_GLOBAL.login_id
            FROM   CSD_REPAIR_TYPES_B RT,
                   CSD_FLOW_STATUSES_B FS_B1,
                   CSD_FLOW_STATUSES_B FS_B2
            WHERE  FS_B1.flow_status_code IN ('C','H','O')
            AND    FS_B2.flow_status_code IN ('C','H','O')
            AND    FS_B2.flow_status_code <> FS_B1.flow_status_code
            AND NOT EXISTS
                   ( SELECT 'x'
                     FROM CSD_FLWSTS_TRANS_B FLWSTS_B
                     WHERE FLWSTS_B.repair_type_id = RT.repair_type_id
                     AND   FLWSTS_B.from_flow_status_id = FS_B1.flow_status_id
                     AND   FLWSTS_B.to_flow_status_id = FS_B2.flow_status_id
                   );

          -- Populate TL table now.

          insert into CSD_FLWSTS_TRANS_TL (
            FLWSTS_TRAN_ID,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            LANGUAGE,
            SOURCE_LANG
          ) select
            FLWSTS_B.flwsts_tran_id,
            NULL, -- P_DESCRIPTION,
            FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.login_id,
            L.LANGUAGE_CODE,
            L.LANGUAGE_CODE
          from FND_LANGUAGES L,
               CSD_FLWSTS_TRANS_B FLWSTS_B
          where L.INSTALLED_FLAG in ('I', 'B')
          and not exists
            (select 'x'
            from CSD_FLWSTS_TRANS_TL T
            where T.FLWSTS_TRAN_ID = FLWSTS_B.flwsts_tran_id
            and T.LANGUAGE = L.LANGUAGE_CODE);

       -- STEP 3: Get all the flow status Ids for use in next steps.

       FOR i IN FlowStatusCodes.FIRST..FlowStatusCodes.LAST LOOP
          SELECT flow_status_id
          INTO   FlowStatusIDs(i)
          FROM   CSD_FLOW_STATUSES_B
          WHERE  flow_status_code = FlowStatusCodes(i);
       END LOOP;

       -- STEP 4: Update all repair types that do not have a value.

          UPDATE CSD_REPAIR_TYPES_B
          SET    start_flow_Status_id = FlowStatusIDs(c_open_index),
		       last_update_date = SYSDATE,
			  last_updated_by = FND_GLOBAL.user_id,
			  last_update_login = FND_GLOBAL.login_id
          WHERE  start_flow_Status_id IS NULL;

       -- STEP 5: Update all repair orders that do not have a value.
       -- Update Inventory_Org_id and Flow_status_id

       -- Repair Inventory Org id derivation
       -- a.If the Repair Order is created by OM relinking process then
       --   the Org Id is derived from the original_source_line_id
       --   of the RO Line.
       -- b.If the RMA/IO is created from Depot, then the Org Id
       --   is derived from the Order line of the corresponding Product
       --   Transaction lines ( RMA/MOVE_IN line)
       -- c.If there are no RMA/MOVE_IN lines then the Organization id of
       --   Item is defaulted as Repair Inv Org id

       OPEN c_get_upd_ro_cursor;

       LOOP
         FETCH c_get_upd_ro_cursor BULK COLLECT INTO repair_line_id_arr,
         original_source_reference_arr,flow_status_id_arr,inventory_org_id_arr,
         inventory_item_id_arr LIMIT MAX_BUFFER_SIZE;

         FOR i IN 1..repair_line_id_arr.COUNT
         LOOP

           l_inv_org_id := null;

           IF ( original_source_reference_arr(i) = 'RMA' ) THEN

             OPEN c_get_om_rma_org_id (repair_line_id_arr(i));
	     FETCH c_get_om_rma_org_id into l_inv_org_id;
             CLOSE c_get_om_rma_org_id;

           ELSE

             OPEN c_get_ro_rma_org_id (repair_line_id_arr(i));
	     FETCH c_get_ro_rma_org_id into l_inv_org_id;
             CLOSE c_get_ro_rma_org_id;

           END IF;

           IF ( l_inv_org_id is null ) THEN

             OPEN c_get_item_org_id (repair_line_id_arr(i));
	     FETCH c_get_item_org_id into l_inv_org_id;
             CLOSE c_get_item_org_id;

           END IF;

           UPDATE CSD_REPAIRS
           SET   flow_Status_id = decode(status,
                                         'O', FlowStatusIDs(c_open_index),
                                         'C', FlowStatusIDs(c_closed_index),
                                         'H', FlowStatusIDs(c_hold_index),
                                         'D', FlowStatusIDs(c_draft_index)
                                         ),
                inventory_org_id  = l_inv_org_id,
		last_update_date  = SYSDATE,
		last_updated_by   = FND_GLOBAL.user_id,
		last_update_login = FND_GLOBAL.login_id
           WHERE  repair_line_id    = repair_line_id_arr(i);

         END LOOP;

         COMMIT;

         EXIT WHEN c_get_upd_ro_cursor%NOTFOUND;

       END LOOP;

       IF c_get_upd_ro_cursor%ISOPEN THEN
         CLOSE c_get_upd_ro_cursor;
       END IF;

       COMMIT;

  END csd_flex_flow_mig6;


/*-----------------------------------------------------------------------------*/
/* procedure name: csd_ro_diagnostic_codes_mig6                                */
/* description   : Migration script for 12.0 Diagnostic Code specific changes. */
/*-----------------------------------------------------------------------------*/

PROCEDURE csd_ro_diagnostic_codes_mig6

    IS

    -- Definitions --
        TYPE REP_LINE_ID_ARRAY_TYPE IS VARRAY (1000)
             OF CSD.CSD_RO_DIAGNOSTIC_CODES.REPAIR_LINE_ID%TYPE;
        TYPE INV_ITEM_ID_ARRAY_TYPE IS VARRAY(1000)
             OF CSD.CSD_REPAIRS.inventory_item_id%TYPE;

    -- Variables --
        rep_line_id_arr  REP_LINE_ID_ARRAY_TYPE;
        inv_item_id_arr  INV_ITEM_ID_ARRAY_TYPE;
        v_error_text     VARCHAR2(2000);

    -- Constants --
        MAX_BUFFER_SIZE  NUMBER  := 500;

    -- Exceptions --
        error_process    EXCEPTION;

    -- Cursors --
        -- cursor to get the repair order items for ro diagnostic codes
        -- that don't have diagnostic item ids.
        CURSOR get_rodc_repair_item_cursor
        IS
          SELECT DISTINCT
            dc.repair_line_id, rep.inventory_item_id
          FROM
            CSD_RO_DIAGNOSTIC_CODES dc,
            CSD_REPAIRS rep
          WHERE dc.diagnostic_item_id IS NULL
            AND rep.repair_line_id = dc.repair_line_id;

    BEGIN


        -- Update all RO diagnostic codes that do not have a diagnostic item.
        -- Default diagnostic item will be the repair order item
        OPEN get_rodc_repair_item_cursor;
	LOOP -- sangigup
        FETCH get_rodc_repair_item_cursor
        BULK COLLECT INTO rep_line_id_arr, inv_item_id_arr LIMIT MAX_BUFFER_SIZE;

        FOR i IN 1..rep_line_id_arr.COUNT
        LOOP


              UPDATE
                CSD_RO_DIAGNOSTIC_CODES
              SET
                diagnostic_item_id = inv_item_id_arr(i)
              WHERE repair_line_id = rep_line_id_arr(i);

	END LOOP;

	COMMIT;

	 EXIT WHEN get_rodc_repair_item_cursor%NOTFOUND;
    END LOOP;

        IF get_rodc_repair_item_cursor%ISOPEN
            THEN
                CLOSE get_rodc_repair_item_cursor;
        END IF;

        COMMIT;

    END csd_ro_diagnostic_codes_mig6;




/*-----------------------------------------------------------------------------*/
/* procedure name: csd_ro_service_codes_mig6                                   */
/* description   : Migration script for 12.0 Diagnostic Code specific changes. */
/*-----------------------------------------------------------------------------*/

    PROCEDURE csd_ro_service_codes_mig6

    IS

    -- Definitions --
        TYPE REP_LINE_ID_ARRAY_TYPE IS VARRAY (1000)
             OF CSD.CSD_RO_SERVICE_CODES.REPAIR_LINE_ID%TYPE;
        TYPE INV_ITEM_ID_ARRAY_TYPE IS VARRAY(1000)
             OF CSD.CSD_REPAIRS.INVENTORY_ITEM_ID%TYPE;

    -- Variables --
        rep_line_id_arr  REP_LINE_ID_ARRAY_TYPE;
        inv_item_id_arr  INV_ITEM_ID_ARRAY_TYPE;
        v_error_text     VARCHAR2(2000);

    -- Constants --
        MAX_BUFFER_SIZE  NUMBER   := 500;

    -- Exceptions --
        error_process    EXCEPTION;

    -- Cursors --
        -- cursor to get the repair order items for ro service codes
        -- that don't have service item ids.
        CURSOR get_rosc_repair_item_cursor
        IS
          SELECT DISTINCT
            sc.repair_line_id, rep.inventory_item_id
          FROM
            CSD_RO_SERVICE_CODES sc,
            CSD_REPAIRS rep
          WHERE sc.service_item_id IS NULL
            AND rep.repair_line_id = sc.repair_line_id;

    BEGIN

        -- Update all RO service codes that do not have a service item.
        -- Default service item will be the repair order item
        OPEN get_rosc_repair_item_cursor;
	LOOP
        FETCH get_rosc_repair_item_cursor
        BULK COLLECT INTO rep_line_id_arr, inv_item_id_arr LIMIT MAX_BUFFER_SIZE;

        FOR i IN 1..rep_line_id_arr.COUNT
        LOOP

              UPDATE
                CSD_RO_SERVICE_CODES
              SET
                service_item_id = inv_item_id_arr(i)
              WHERE repair_line_id = rep_line_id_arr(i);
              --  AND service_item_id IS NULL;

        END LOOP;

	COMMIT;

	 EXIT WHEN get_rosc_repair_item_cursor%NOTFOUND;
     END LOOP;

        IF get_rosc_repair_item_cursor%ISOPEN
            THEN
                CLOSE get_rosc_repair_item_cursor;
        END IF;
        COMMIT;
    END csd_ro_service_codes_mig6;

END CSD_Migrate_From_115X_PKG6;

/
