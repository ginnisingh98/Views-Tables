--------------------------------------------------------
--  DDL for Package Body INV_REDUCE_MOQD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_REDUCE_MOQD_PVT" AS
/* $Header: INVRMOQB.pls 120.2.12010000.4 2009/07/09 09:20:31 gjyoti ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_REDUCE_MOQD_PVT';
g_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0); /* Added for bug 7588761 */
g_lock_handle VARCHAR2(128) :='';    /* Added for bug 7588761 */

    PROCEDURE debug(
        p_message  IN  VARCHAR2
        ) IS
    BEGIN
        inv_log_util.trace(p_message, G_PKG_NAME , 10 );
    EXCEPTION
        WHEN OTHERS THEN
             NULL;
    END debug;


    /* Added following new function for proper lock handling for bug 7588761 */
    FUNCTION get_lock_handle (
        p_request_id NUMBER,
        p_org_id     NUMBER,
        p_item_id    NUMBER
        ) RETURN VARCHAR2 IS
        /* Changed order of parameters for bug 8662708 */
       PRAGMA AUTONOMOUS_TRANSACTION;
       l_lock_handle VARCHAR2(128);
       l_lock_name   VARCHAR2(128); /* Increased width for bug 8662708 */
    BEGIN

      l_lock_name := 'INV_CMOQD_'||p_request_id||'_'|| p_org_id || '_' || p_item_id;
      if (g_debug = 1) then
          debug('get lock handler '||l_lock_name);
      end if;

      dbms_lock.allocate_unique(
         lockname   => l_lock_name
        ,lockhandle => l_lock_handle);

      return l_lock_handle;

    END get_lock_handle;

    /* Added following new procedure for proper lock handling for bug 7588761 */
    PROCEDURE release_locks (
        p_request_id NUMBER,
        p_item_id    NUMBER,
        p_org_id     NUMBER,
        x_err_code   OUT NOCOPY NUMBER,
        x_err_msg    OUT NOCOPY VARCHAR2
        ) IS

       l_lock_handle VARCHAR2(128);

    BEGIN

       if (p_request_id is null or p_org_id is null or p_item_id is null) then

          fnd_message.set_name('INV','INV_LOCK_RELEASE_MISSING_ARGS');
          x_err_msg := fnd_message.get;
          fnd_file.put_line(fnd_file.log, x_err_msg);
          rollback;
       end if;

       l_lock_handle := get_lock_handle (p_request_id, p_org_id, p_item_id);

       if(g_debug = 1) then
         debug('Release the lock : '||l_lock_handle);
       end if;

       x_err_code := dbms_lock.release(l_lock_handle);
       -- parameter error,illegal lockhandle
       if x_err_code IN (3,5) THEN
          fnd_message.set_name('INV','INV_LOCK_RELEASE_ERROR');
          x_err_msg := fnd_message.get;
          fnd_file.put_line(fnd_file.log, x_err_msg);
          rollback;
       end if;

       g_lock_handle :='';

    END release_locks;

    /* Added following new procedure for proper lock handling for bug 7588761 */
    PROCEDURE lock_org_item (
        p_request_id NUMBER,
        p_item_id    NUMBER,
        p_org_id     NUMBER,
        x_err_code   OUT NOCOPY NUMBER,
        x_err_msg    OUT NOCOPY VARCHAR2
        ) IS

       l_lock_handle VARCHAR2(128);

        CURSOR C IS
        SELECT  *
        FROM MTL_ONHAND_QUANTITIES_DETAIL
        WHERE ORGANIZATION_ID = p_org_id
          AND INVENTORY_ITEM_ID = p_item_id
        FOR UPDATE NOWAIT;


    BEGIN
        l_lock_handle :=get_lock_handle (p_request_id, p_org_id, p_item_id);

        if(g_debug = 1) then
          debug('Got the lockhandle : '||l_lock_handle);
        end if;

        x_err_code := dbms_lock.request(
        lockhandle        => l_lock_handle
        ,lockmode          => dbms_lock.x_mode
        ,timeout           => dbms_lock.maxwait
        ,release_on_commit => TRUE);


        if (x_err_code not in (0,4)) then
          if (x_err_code = 1 or x_err_code = 2) then -- timeout
             rollback;
          else -- internal error - not fault of user
             x_err_code := SQLCODE;
             x_err_msg  := substr('Error request lock: ' || SQLERRM, 1, 2000);
             rollback;
          end if;
        elsif (x_err_code = 0 ) then
          g_lock_handle := l_lock_handle;
          open c;
          close c;
        end if;

    EXCEPTION
        WHEN app_exceptions.record_lock_exception  THEN
             x_err_code :=1;
             x_err_msg  := substr('Exception in LOCK_ORG_ITEM: ' || SQLERRM, 1, 2000);
        WHEN OTHERS THEN
             x_err_code := SQLCODE;
             x_err_msg  := substr('Error in LOCK_ORG_ITEM: ' || SQLERRM, 1, 2000);

    END lock_org_item;

    PROCEDURE consolidate_moqd(
        ERRBUF OUT NOCOPY VARCHAR2 ,
        RETCODE OUT NOCOPY NUMBER ,
        P_ORG_ID IN NUMBER
        ) IS

        /* Commented for bug 7588761 */
        -- l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        l_profile VARCHAR2(1) := NVL(FND_PROFILE.VALUE('INV_FIFO_ORIG_REC_DATE'),'N');
        l_user_id NUMBER := NVL(FND_PROFILE.VALUE('USER_ID'),-999);
        l_request_id NUMBER := NVL(FND_PROFILE.VALUE('CONC_REQUEST_ID'),-999);

        l_moq_count NUMBER;
        l_moq_sum   NUMBER;
        l_moq_backup_count NUMBER;
        l_moq_backup_sum NUMBER;
        l_moq_sec_sum   NUMBER;
        l_moq_sec_backup_sum   NUMBER;

        l_stmt_count NUMBER ;
        l_return_status VARCHAR2(30);
        l_conc_status BOOLEAN;

        l_err_msg  varchar2(2000);  /* Added for bug 7588761 */
        l_err_code number;          /* Added for bug 7588761 */
        l_proc_cnt NUMBER;          /* Added for bug 7588761 */

        l_ret BOOLEAN;

        l_org_id NUMBER;
        l_org_code VARCHAR2(3);

        l_prof_cnt NUMBER;
        l_resource NUMBER;
         /* Commented for bug 7588761
        RESOURCE_BUSY   EXCEPTION;
        PRAGMA EXCEPTION_INIT(RESOURCE_BUSY ,-54);
         */

        -- Bug 7681955
        -- Allow for process enabled orgs.
        CURSOR elig_orgs IS
        SELECT mp.organization_id, mp.organization_code
        FROM  mtl_parameters mp
        WHERE mp.organization_id = P_ORG_ID
        AND  mp.wms_enabled_flag = 'N';
        -- OR  mp.process_enabled_flag = 'Y');

        /* Commented for bug 7588761
         CURSOR lock_moqd IS */

        CURSOR moqd_org_item (p_org_id NUMBER) IS
        SELECT  ORGANIZATION_ID, INVENTORY_ITEM_ID
        FROM MTL_ONHAND_QUANTITIES_DETAIL
        WHERE ORGANIZATION_ID = P_ORG_ID
        GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID;
         -- FOR UPDATE NOWAIT; /* commented for bug 7588761 */
    BEGIN
        RETCODE := 0;

        l_stmt_count := 50;

        IF P_ORG_ID IS NULL THEN
            IF(g_debug = 1) THEN
                debug('The parameter P_ORG_ID cannot be NULL');
            END IF;
            RETCODE := 2;
            FND_MESSAGE.set_name('INV','INV_MOQD_REQ_ERR');
            -- Consolidation of Onhand Quantities failed.
            ERRBUF := FND_MESSAGE.get;
            FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
            l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
            ROLLBACK;
            RETURN;
        END IF;

        l_stmt_count := 100;

    -- If fnd_profile returns 'N' for the profile, then make sure that this profile is not
    -- set to 'Y' at any other levels before proceeding with onhand consolidation.

        IF (l_profile = 'N') THEN

            l_stmt_count := 110;

              SELECT count(1) INTO l_prof_cnt
              FROM  fnd_profile_options o, fnd_profile_option_values v
              WHERE o.profile_option_name = 'INV_FIFO_ORIG_REC_DATE'
              AND   o.start_date_active <= sysdate
              AND   (nvl(o.end_date_active,sysdate) >= sysdate)
              AND   o.profile_option_id = v.profile_option_id
              AND   o.application_id    = v.application_id
              AND   nvl(v.profile_option_value,'N') = 'Y' ;

            l_stmt_count := 120;

            IF (l_prof_cnt > 0) THEN
                IF(g_debug = 1) THEN
                    debug('The Profile INV: FIFO for Original Receipt Date is set to Yes at Appl/Resp/User Level');
                END IF;
                RETCODE := 2;
                FND_MESSAGE.set_name('INV','INV_MOQD_FIFO_SET');
                -- The Profile INV: FIFO for Original Receipt Date is set to Yes and this program should not be run when the option is set to Yes.
                ERRBUF := FND_MESSAGE.get;
                FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
                l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
                ROLLBACK;
                RETURN;
            END IF;
        ELSE    -- l_profile = 'Y'

            l_stmt_count := 130;

            -- The error message says it all.
            IF(g_debug = 1) THEN
                debug('The Profile INV: FIFO for Original Receipt Date is set to Yes and this program should not be run when this option is set to Yes');
            END IF;
            RETCODE := 2;
            FND_MESSAGE.set_name('INV','INV_MOQD_FIFO_SET');
            -- The Profile INV: FIFO for Original Receipt Date is set to Yes and this program should not be run when the option is set to Yes.
            ERRBUF := FND_MESSAGE.get;
            FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
            l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
            ROLLBACK;
            RETURN;
        END IF;

        l_stmt_count := 150;
       -- BEGIN

        -- Lock all the rows in MOQD for that Org_id using lock_moqd cursor

            BEGIN
                OPEN elig_orgs;
                FETCH elig_orgs INTO l_org_id, l_org_code;
                IF elig_orgs%NOTFOUND THEN
                    IF(g_debug = 1) THEN
                        -- Bug 7681955
                        -- Allow for process enabled orgs.
                        debug('This Organization is WMS enabled'); /* or Process enabled'); */
                    END IF;
                    RETCODE := 2;
                    FND_MESSAGE.set_name('INV','INV_MOQD_REQ_ERR');
                    -- Consolidation of Onhand Quantities failed.
                    FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
                    l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
                    RETURN;
                END IF;
                CLOSE elig_orgs;
            END;

            /* Commented for Bug 7588761

            OPEN lock_moqd;
            CLOSE lock_moqd;

            EXCEPTION
                WHEN RESOURCE_BUSY THEN
                  IF(g_debug = 1) THEN
                    debug('Cannot obtain locks on MOQD');
                  END IF;

                  -- Just for pre-caution
                  IF (lock_moqd%ISOPEN) THEN
                    CLOSE lock_moqd;
                  END IF;

                RETCODE := 2;
                FND_MESSAGE.set_name('INV','INV_MOQD_CANNOT_LOCK');
                -- The Onhand Quantities table cannot be locked for consolidation.
                ERRBUF := FND_MESSAGE.get;
                FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
                l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
                ROLLBACK;
                RETURN;
            END;
                            */
            l_proc_cnt := 0;
            /* Modified following loop for bug 7588761 */

            FOR l_moqd in moqd_org_item(l_org_id) LOOP
                if(g_debug = 1) then
                    debug('-----------------------------------------------');
                    debug('Running for Org - '||l_org_code||', Id = '||l_org_id);
                end if;
                if (g_debug = 1) then
                    debug('lock on moqd for org_id' ||l_moqd.ORGANIZATION_ID||' and item '||l_moqd.INVENTORY_ITEM_ID );
                end if;
                /* Start of changes for bug 7588761 */
                lock_org_item (
                  p_request_id =>l_request_id,
                  p_item_id    =>l_moqd.INVENTORY_ITEM_ID,
                  p_org_id     =>l_moqd.ORGANIZATION_ID,
                  x_err_code   =>l_err_code,
                  x_err_msg    =>l_err_msg
                  );

                if l_err_code = 0 then      -- lock granted
                    if (g_debug = 1) then
                      debug('Lock granted on item_id '||l_moqd.INVENTORY_ITEM_ID );
                    end if;
                    l_stmt_count := 200;
                    --delete non-summarized rows from mtl_moq_backup table
                    DELETE FROM mtl_moqd_backup
                    WHERE summarized_flag = 'N';

                    l_stmt_count := 300;

                    /* Commented following for bug 7588761 */
                    /*
                    -- Go thru the loop for the eligible org
                    FOR elig_orgs_rec in elig_orgs LOOP

                        IF(g_debug = 1) THEN
                            debug('-----------------------------------------------');
                            debug('Running for Org - '||elig_orgs_rec.organization_code||', Id = '||elig_orgs_rec.organization_id);
                        END IF;
                    */
                    --copy records from mtl_onhand_quantities_detail into mtl_moq_backup table
                    /* Added inventory_item_id condition for bug 7588761 */
                    INSERT INTO MTL_MOQD_BACKUP(
                     INVENTORY_ITEM_ID
                    ,ORGANIZATION_ID
                    ,DATE_RECEIVED
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,PRIMARY_TRANSACTION_QUANTITY
                    ,SUBINVENTORY_CODE
                    ,REVISION
                    ,LOCATOR_ID
                    ,CREATE_TRANSACTION_ID
                    ,UPDATE_TRANSACTION_ID
                    ,LOT_NUMBER
                    ,ORIG_DATE_RECEIVED
                    ,COST_GROUP_ID
                    ,CONTAINERIZED_FLAG
                    ,PROJECT_ID
                    ,TASK_ID
                    ,ONHAND_QUANTITIES_ID
                    ,ORGANIZATION_TYPE
                    ,OWNING_ORGANIZATION_ID
                    ,OWNING_TP_TYPE
                    ,PLANNING_ORGANIZATION_ID
                    ,PLANNING_TP_TYPE
                    ,TRANSACTION_UOM_CODE
                    ,TRANSACTION_QUANTITY
                    ,SECONDARY_UOM_CODE
                    ,SECONDARY_TRANSACTION_QUANTITY
                    ,IS_CONSIGNED
                    ,ROW_ID
                    ,SUMMARIZED_FLAG
                    )
                    SELECT
                     INVENTORY_ITEM_ID
                    ,ORGANIZATION_ID
                    ,DATE_RECEIVED
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,PRIMARY_TRANSACTION_QUANTITY
                    ,SUBINVENTORY_CODE
                    ,REVISION
                    ,LOCATOR_ID
                    ,CREATE_TRANSACTION_ID
                    ,UPDATE_TRANSACTION_ID
                    ,LOT_NUMBER
                    ,ORIG_DATE_RECEIVED
                    ,COST_GROUP_ID
                    ,CONTAINERIZED_FLAG
                    ,PROJECT_ID
                    ,TASK_ID
                    ,ONHAND_QUANTITIES_ID
                    ,ORGANIZATION_TYPE
                    ,OWNING_ORGANIZATION_ID
                    ,OWNING_TP_TYPE
                    ,PLANNING_ORGANIZATION_ID
                    ,PLANNING_TP_TYPE
                    ,TRANSACTION_UOM_CODE
                    ,TRANSACTION_QUANTITY
                    ,SECONDARY_UOM_CODE
                    ,SECONDARY_TRANSACTION_QUANTITY
                    ,IS_CONSIGNED
                    ,ROWID
                     ,'N'
                    FROM MTL_ONHAND_QUANTITIES_DETAIL
                    WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                    AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                    AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                    AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                    AND PLANNING_TP_TYPE = 2
                    AND OWNING_TP_TYPE = 2;
                    -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0; -- Bug 7681955

                    IF(g_debug = 1) THEN
                        debug('Finished insert into MTL_MOQD_BACKUP');
                    END IF;

                    l_stmt_count := 310;

                    --check count(*) to make sure copy went okay
                    /* Added inventory_item_id condition for bug 7588761 */
                    SELECT count(*)
                    INTO l_moq_count
                    FROM mtl_onhand_quantities_detail moqd
                    WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                    AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                    AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                    AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                    AND PLANNING_TP_TYPE = 2
                    AND OWNING_TP_TYPE = 2
                    -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0 -- Bug 7681955
                    AND ROWID IN (SELECT ROW_ID FROM MTL_MOQD_BACKUP mmb
                                  WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                                  AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                                  AND SUMMARIZED_FLAG = 'N');

                    l_stmt_count := 320;

                    SELECT count(*)
                    INTO l_moq_backup_count
                    FROM mtl_moqd_backup
                    WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                    AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID  /* Added for bug 7588761 */
                    AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                    AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                    AND PLANNING_TP_TYPE = 2
                    AND OWNING_TP_TYPE = 2
                    -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0    -- Bug 7681955
                    AND SUMMARIZED_FLAG = 'N';

                    l_stmt_count := 330;

                    IF(g_debug = 1) THEN
                        debug('MOQD count: ' || l_moq_count);
                        debug('MOQD_BACKUP count: ' || l_moq_backup_count);
                    END IF;

                    If l_moq_count <> l_moq_backup_count Then
                         IF(g_debug = 1) THEN
                            debug('MOQD and Backup Count are not same');
                         END IF;
                         RETCODE := 2;
                         FND_MESSAGE.set_name('INV','INV_MOQD_REQ_ERR');
                         -- Consolidation of Onhand Quantities failed.
                         ERRBUF := FND_MESSAGE.get;
                         FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
                         l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
                         ROLLBACK;
                         -- RETURN;  /* Commented for bug 7588761  */
                         goto loop_end;  /* Added for bug 7588761 */

                    END IF;
                    IF l_moq_count <> 0 THEN
                        l_stmt_count := 340;

                        --delete records from mtl_onhand_quantities_detail in that Org
                         /* Added inventory_item_id condition for bug 7588761 */
                        delete from mtl_onhand_quantities_detail moqd
                        WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                        AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                        AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND PLANNING_TP_TYPE = 2
                        AND OWNING_TP_TYPE = 2
                        -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0 -- Bug 7681955
                        AND ROWID IN (SELECT ROW_ID FROM MTL_MOQD_BACKUP mmb
                                       WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                                         AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                                         AND SUMMARIZED_FLAG = 'N');

                        IF(g_debug = 1) THEN
                           debug('Deleted '||SQL%ROWCOUNT||' rows from MOQD');
                        END IF;

                        l_stmt_count := 350;

                        --copy grouped records from mtl_moq_backup into mtl_onhand_quantities_detail
                        insert into mtl_onhand_quantities_detail(
                         INVENTORY_ITEM_ID
                        ,ORGANIZATION_ID
                        ,DATE_RECEIVED
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,PRIMARY_TRANSACTION_QUANTITY
                        ,SUBINVENTORY_CODE
                        ,REVISION
                        ,LOCATOR_ID
                        ,CREATE_TRANSACTION_ID
                        ,UPDATE_TRANSACTION_ID
                        ,LOT_NUMBER
                        ,ORIG_DATE_RECEIVED
                        ,COST_GROUP_ID
                        ,CONTAINERIZED_FLAG
                        ,PROJECT_ID
                        ,TASK_ID
                        ,ONHAND_QUANTITIES_ID
                        ,ORGANIZATION_TYPE
                        ,OWNING_ORGANIZATION_ID
                        ,OWNING_TP_TYPE
                        ,PLANNING_ORGANIZATION_ID
                        ,PLANNING_TP_TYPE
                        ,TRANSACTION_UOM_CODE
                        ,TRANSACTION_QUANTITY
                        ,SECONDARY_UOM_CODE
                        ,SECONDARY_TRANSACTION_QUANTITY
                        ,IS_CONSIGNED
                        )
                        SELECT
                         INVENTORY_ITEM_ID
                        ,ORGANIZATION_ID
                        ,MIN(DATE_RECEIVED)
                        ,MIN(LAST_UPDATE_DATE)
                        ,MIN(LAST_UPDATED_BY)
                        ,MIN(CREATION_DATE)
                        ,MIN(CREATED_BY)
                        ,MIN(LAST_UPDATE_LOGIN)
                        ,ROUND(SUM(PRIMARY_TRANSACTION_QUANTITY),5)
                        ,SUBINVENTORY_CODE
                        ,REVISION
                        ,LOCATOR_ID
                        ,MIN(CREATE_TRANSACTION_ID)
                        ,MAX(UPDATE_TRANSACTION_ID) --Capturing Max(update_transaction_id)
                        ,LOT_NUMBER
                        ,MIN(ORIG_DATE_RECEIVED)
                        ,COST_GROUP_ID
                        ,NVL(CONTAINERIZED_FLAG,2) CONTAINERIZED_FLAG
                        ,PROJECT_ID
                        ,TASK_ID
                        ,MIN(ONHAND_QUANTITIES_ID)
                        ,ORGANIZATION_TYPE
                        ,OWNING_ORGANIZATION_ID
                        ,OWNING_TP_TYPE
                        ,PLANNING_ORGANIZATION_ID
                        ,PLANNING_TP_TYPE
                        ,TRANSACTION_UOM_CODE
                        ,ROUND(SUM(PRIMARY_TRANSACTION_QUANTITY),5)
                        ,SECONDARY_UOM_CODE
                        ,ROUND(SUM(SECONDARY_TRANSACTION_QUANTITY),5)
                        ,IS_CONSIGNED
                        FROM MTL_MOQD_BACKUP
                        WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                        AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                        AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND PLANNING_TP_TYPE = 2
                        AND OWNING_TP_TYPE = 2
                        -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0
                        AND SUMMARIZED_FLAG = 'N'
                        GROUP BY
                          INVENTORY_ITEM_ID,
                          ORGANIZATION_ID,
                          SUBINVENTORY_CODE,
                          REVISION,
                          LOCATOR_ID,
                          LOT_NUMBER,
                          COST_GROUP_ID,
                          PROJECT_ID,
                          TASK_ID,
                          NVL(CONTAINERIZED_FLAG,2),
                          ORGANIZATION_TYPE,
                          OWNING_ORGANIZATION_ID,
                          OWNING_TP_TYPE,
                          PLANNING_ORGANIZATION_ID,
                          PLANNING_TP_TYPE,
                          TRANSACTION_UOM_CODE,
                          SECONDARY_UOM_CODE,
                          IS_CONSIGNED
                        HAVING ( ROUND(SUM(PRIMARY_TRANSACTION_QUANTITY),5) <> 0
                        OR ROUND(SUM(SECONDARY_TRANSACTION_QUANTITY),5) <> 0) ; -- Bug 7681955 Added OR secondary qty <> 0

                         IF(g_debug = 1) THEN
                            debug('Inserted '||SQL%ROWCOUNT||' rows into MOQD');
                         END IF;

                        l_stmt_count := 360;

                        --check sum to see if any quantities have been lost
                         /* Added inventory_item_id condition for bug 7588761 */
                         /* Bug 7681955 Added secondary qty check */
                        SELECT nvl(sum(primary_transaction_quantity) ,0), nvl(sum(secondary_transaction_quantity) ,0)
                        INTO l_moq_sum, l_moq_sec_sum
                        FROM mtl_onhand_quantities_detail
                        WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                        AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                        AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND PLANNING_TP_TYPE = 2
                        AND OWNING_TP_TYPE = 2;
                        -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0;  -- Bug 7681955

                        l_stmt_count := 370;

                        /* Bug 7681955 Added secondary qty check */
                        SELECT nvl(sum(primary_transaction_quantity) ,0), nvl(sum(secondary_transaction_quantity) ,0)
                        INTO l_moq_backup_sum, l_moq_sec_backup_sum
                        FROM mtl_moqd_backup
                        WHERE ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                        AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                        AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND PLANNING_TP_TYPE = 2
                        AND OWNING_TP_TYPE = 2
                        -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0  -- Bug 7681955
                        AND SUMMARIZED_FLAG = 'N';

                        l_stmt_count := 380;

                        IF(g_debug = 1) THEN
                            debug('Sum of Pri Qty in MOQD : ' || l_moq_sum);
                            debug('Sum of Pri Qty in MOQD_BACKUP : ' || l_moq_backup_sum);
                            debug('Sum of Sec Qty in MOQD : ' || l_moq_sec_sum);
                            debug('Sum of Sec Qty in MOQD_BACKUP : ' || l_moq_sec_backup_sum);
                        END IF;

                        /* Bug 7681955 Added secondary qty check */
                        IF ( l_moq_sum <> l_moq_backup_sum OR l_moq_sec_sum <> l_moq_sec_backup_sum) Then
                             IF(g_debug = 1) THEN
                                 debug('Sum of MOQ Qty and Backup Qty Count are not same');
                             END IF;
                             RETCODE := 2;
                             FND_MESSAGE.set_name('INV','INV_MOQD_REQ_ERR');
                             -- Consolidation of Onhand Quantities failed.
                             ERRBUF := FND_MESSAGE.get;
                             FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
                             l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
                             ROLLBACK;
                             -- RETURN; /* Commented for bug 7588761  */
                            goto loop_end; /* Added for bug 7588761 */
                        END IF;

                        l_stmt_count := 385;

                        -- Insert Summary records into mtl_moq_backup table capturing the user_id,
                        -- request_id and request run date.

                     /* Added inventory_item_id condition for bug 7588761 */
                        INSERT INTO MTL_MOQD_BACKUP(
                         INVENTORY_ITEM_ID
                        ,ORGANIZATION_ID
                        ,DATE_RECEIVED
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,PRIMARY_TRANSACTION_QUANTITY
                        ,SUBINVENTORY_CODE
                        ,REVISION
                        ,LOCATOR_ID
                        ,CREATE_TRANSACTION_ID
                        ,UPDATE_TRANSACTION_ID
                        ,LOT_NUMBER
                        ,ORIG_DATE_RECEIVED
                        ,COST_GROUP_ID
                        ,CONTAINERIZED_FLAG
                        ,PROJECT_ID
                        ,TASK_ID
                        ,ONHAND_QUANTITIES_ID
                        ,ORGANIZATION_TYPE
                        ,OWNING_ORGANIZATION_ID
                        ,OWNING_TP_TYPE
                        ,PLANNING_ORGANIZATION_ID
                        ,PLANNING_TP_TYPE
                        ,TRANSACTION_UOM_CODE
                        ,TRANSACTION_QUANTITY
                        ,SECONDARY_UOM_CODE
                        ,SECONDARY_TRANSACTION_QUANTITY
                        ,IS_CONSIGNED
                        ,SUMMARIZED_FLAG
                        ,REQUEST_ID
                        ,USER_ID
                        ,CONSOLIDATION_DATE
                        ,ROW_ID
                        )
                        SELECT
                         INVENTORY_ITEM_ID
                        ,ORGANIZATION_ID
                        ,DATE_RECEIVED
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,PRIMARY_TRANSACTION_QUANTITY
                        ,SUBINVENTORY_CODE
                        ,REVISION
                        ,LOCATOR_ID
                        ,CREATE_TRANSACTION_ID
                        ,UPDATE_TRANSACTION_ID
                        ,LOT_NUMBER
                        ,ORIG_DATE_RECEIVED
                        ,COST_GROUP_ID
                        ,CONTAINERIZED_FLAG
                        ,PROJECT_ID
                        ,TASK_ID
                        ,ONHAND_QUANTITIES_ID
                        ,ORGANIZATION_TYPE
                        ,OWNING_ORGANIZATION_ID
                        ,OWNING_TP_TYPE
                        ,PLANNING_ORGANIZATION_ID
                        ,PLANNING_TP_TYPE
                        ,TRANSACTION_UOM_CODE
                        ,TRANSACTION_QUANTITY
                        ,SECONDARY_UOM_CODE
                        ,SECONDARY_TRANSACTION_QUANTITY
                        ,IS_CONSIGNED
                        ,'Y'
                        ,l_request_id
                        ,l_user_id
                        ,SYSDATE
                        ,ROWID
                        FROM MTL_ONHAND_QUANTITIES_DETAIL
                        WHERE  ORGANIZATION_ID = l_moqd.ORGANIZATION_ID
                        AND INVENTORY_ITEM_ID = l_moqd.INVENTORY_ITEM_ID
                        AND PLANNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND OWNING_ORGANIZATION_ID = ORGANIZATION_ID
                        AND PLANNING_TP_TYPE = 2
                        AND OWNING_TP_TYPE = 2;
                        -- AND NVL(SECONDARY_TRANSACTION_QUANTITY,0) = 0;   -- Bug 7681955

                        IF(g_debug = 1) THEN
                            debug('Inserted '||SQL%ROWCOUNT||' rows into MOQD_BACKUP as Summary Rows');
                        END IF;

                        l_stmt_count := 390;

                        -- Delete all non-summary records from mtl_moq_backup table
                        DELETE FROM MTL_MOQD_BACKUP
                        WHERE SUMMARIZED_FLAG = 'N';

                        IF(g_debug = 1) THEN
                            debug('Deleted '||SQL%ROWCOUNT||' Non-Summary rows from MOQD_BACKUP');
                        END IF;
                    END IF; --IF l_moq_count <> 0 THEN

                    /* Start of changes for bug 7588761 */
                    commit;  --for each item

                    <<loop_end>>
                    -- we should release the lock handle at the end of the process
                    release_locks (
                          p_request_id =>l_request_id,
                          p_item_id    =>l_moqd.INVENTORY_ITEM_ID,
                          p_org_id     =>l_moqd.ORGANIZATION_ID,
                          x_err_code   =>l_err_code,
                          x_err_msg    =>l_err_msg
                         );
                    l_proc_cnt := l_proc_cnt + 1;

                ELSIF l_err_code <> 0 THEN   -- failed to lock this item

                    IF (g_debug = 1) THEN
                        debug('Not able to get lock on item_id '||l_moqd.INVENTORY_ITEM_ID );
                    END IF;
                    debug(l_err_msg);
                    -- not able to lock on item, release the lock requested.
                    release_locks (
                      p_request_id =>l_request_id,
                      p_item_id    =>l_moqd.INVENTORY_ITEM_ID,
                      p_org_id     =>l_moqd.ORGANIZATION_ID,
                      x_err_code   =>l_err_code,
                      x_err_msg    =>l_err_msg
                     );
                END IF;
                    /* End of changes for bug 7588761 */

            END LOOP;  -- moqd_org_item loop

            l_stmt_count := 400;

            IF(g_debug = 1) THEN
            debug('Completed Successfully, total number of item processed '||l_proc_cnt);
            END IF;

            RETCODE := 1;
            FND_MESSAGE.set_name('INV','INV_MOQD_REQ_SUCC');
            -- Consolidation of Onhand Quantities completed successfully.
            ERRBUF := FND_MESSAGE.get;
            l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',ERRBUF);

           --COMMIT; /* Commented for bug 7588761 */
            RETURN;

    EXCEPTION
       WHEN OTHERS then
            IF(g_debug = 1) THEN
                debug('Error during script, Statement = '||l_stmt_count);
                debug('Rolling back... Error Message = ' ||SQLERRM);
            END IF;
            RETCODE := 2;
            FND_MESSAGE.set_name('INV','INV_MOQD_REQ_ERR');
            -- Consolidation of Onhand Quantities failed.
            ERRBUF := FND_MESSAGE.get;
            l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
            /* Added following if condition for bug 7588761 */
            /* we should release any outstanding locks */
            if g_lock_handle is not null then
               l_err_code := dbms_lock.release(g_lock_handle);
            end if;

            ROLLBACK;
            RETURN;
    END;

END INV_REDUCE_MOQD_PVT;

/
