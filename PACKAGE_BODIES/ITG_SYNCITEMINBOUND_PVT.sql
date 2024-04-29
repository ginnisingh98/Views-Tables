--------------------------------------------------------
--  DDL for Package Body ITG_SYNCITEMINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SYNCITEMINBOUND_PVT" AS
/* ARCS: $Header: itgvsiib.pls 120.5 2006/01/23 03:48:14 bsaratna noship $
 * CVS:  itgvsiib.pls,v 1.29 2002/12/23 21:20:30 ecoe Exp
 */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ITG_SyncItemInbound_PVT';
  l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
  g_action VARCHAR2(100) := 'Item Synchronization';

  /* Private functions and procedures */


  /* Apps Business Object API call: ITG_SyncItemInbound_PVT.Sync_Item */
  PROCEDURE Sync_Item(
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,

        /* See original code/comment in poisibio.sql (bug #1672639). */
        p_syncind          IN         VARCHAR2,             /* (1) */
        p_org_id           IN         NUMBER,               /* poentity */
        p_hazrdmatl        IN         VARCHAR2,
        p_create_date      IN         DATE     := NULL,
        p_item             IN         VARCHAR2,
        p_uom              IN         VARCHAR2,
        p_itemdesc         IN         VARCHAR2,
        p_itemstatus       IN         VARCHAR2,
        p_itemtype         IN         VARCHAR2,
        p_rctrout          IN         VARCHAR2,             /* ref_rctrout */
        p_commodity1       IN         VARCHAR2,
        p_commodity2       IN         VARCHAR2
  )
  IS
        PRAGMA AUTONOMOUS_TRANSACTION;  /* enable commit/rollback */
        /* Business object constants. */
        l_api_name    CONSTANT VARCHAR2(30) := 'Sync_Item';
        l_api_version CONSTANT NUMBER       := 1.0;

        l_itemarray            FND_FLEX_EXT.SegmentArray;
        l_hazard_class_id      po_hazard_classes.hazard_class_id%TYPE;
        l_nested_exception     EXCEPTION;


        l_create_date          DATE;

        l_num                  NUMBER;
        l_set_process_id       NUMBER;
        l_org_tmp              NUMBER;
        l_ccm_request_id       NUMBER;

        l_sii_rowid            ROWID;
        l_ici_rowid            ROWID;

        l_bool                 BOOLEAN;

        l_syncind              VARCHAR2(1);
        l_sync_tmp             VARCHAR2(1);
        l_phase                VARCHAR2(400);
        l_status               VARCHAR2(400);
        l_dev_phase            VARCHAR2(400);
        l_dev_status           VARCHAR2(400);
        l_reap_status          VARCHAR2(20);
        l_errmsg               VARCHAR2(4000);
  BEGIN
        /* Initialize return status */
        x_return_status         := FND_API.G_RET_STS_SUCCESS;
        g_action                := 'Item synchronization';

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering Sync_Item ---' ,2);
        END IF;

        BEGIN
                ITG_Debug.setup(
                        p_reset     => TRUE,
                        p_pkg_name  => G_PKG_NAME,
                        p_proc_name => l_api_name
                );


                -- in wrapper now > FND_MSG_PUB.Initialize;
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('SI - Top of procedure.' ,1);
                        itg_debug_pub.Add('SI - p_syncind'  ||p_syncind,1);
                        itg_debug_pub.Add('SI - p_org_id'   ||p_org_id,1);
                        itg_debug_pub.Add('SI - p_hazrdmatl'||p_hazrdmatl,1);
                        itg_debug_pub.Add('SI - p_create_date'||p_create_date,1);
                        itg_debug_pub.Add('SI - p_item'     ||p_item,1);
                        itg_debug_pub.Add('SI - p_uom'      ||p_uom,1);
                        itg_debug_pub.Add('SI - p_itemdesc' ||p_itemdesc,1);
                        itg_debug_pub.Add('SI - p_itemstatus'||p_itemstatus,1);
                        itg_debug_pub.Add('SI - p_itemtype' ||p_itemtype,1);
                        itg_debug_pub.Add('SI - p_rctrout'  ||p_rctrout,1);
                        itg_debug_pub.Add('SI - p_commodity1'||p_commodity1,1);
                        itg_debug_pub.Add('SI - p_commodity2'||p_commodity2,1);
                END IF;


                l_syncind := UPPER(p_syncind);

                /* Validation block */
                DECLARE
                        l_param_name    VARCHAR2(30)   := NULL;
                        l_param_value   VARCHAR2(2000) := 'NULL';
                        l_cnt           NUMBER;
                BEGIN
                        g_action := 'Item-sync parameter validation';

                        IF p_item IS NULL THEN
                                l_param_name  := 'ITEM';
                        ELSIF l_syncind NOT IN ('A', 'C') THEN
                                l_param_name  := 'SYNCIND';
                                l_param_value := l_syncind;
                        ELSIF p_uom IS NULL THEN
                                l_param_name  := 'UOM';
                        END IF;

                        IF l_param_name IS NOT NULL THEN
                                ITG_MSG.missing_element_value(l_param_name, l_param_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        SELECT count(1)
                        INTO   l_cnt
                        FROM   mtl_units_of_measure_vl
                        WHERE  UPPER(uom_code) = UPPER(p_uom);

                        IF l_cnt = 0 THEN
                                ITG_MSG.uom_not_found(p_uom);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('SI - Completed validations' ,1);
                END IF;

                /* TBD: bug comment from original  */

                /* Bug #1672639 (Forward port of 11.0 bug#1588435).  Work around
                   until we can retrieve proper delimiter from flex meta data.
                   Treats all items as single segment.  This code was replaced:

                   l_num := fnd_flex_ext.breakup_segments(
                                :new.itemheader.item, '-', l_itemarray);

                    with the following 2 lines:
                */

                l_itemarray(1)   := p_item;
                l_num            := 1;

                /* Fill out rest of array with NULLs (or insert will fail) */
                FOR i IN 1 .. 20 LOOP
                        IF i > l_num THEN
                                l_itemarray(i) := NULL;
                        END IF;
                END LOOP;

                IF p_hazrdmatl IS NOT NULL THEN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('SI - Loading hazard class ID',1 );
                        END IF;

                        BEGIN
                                SELECT hazard_class_id
                                INTO   l_hazard_class_id
                                FROM   po_hazard_classes
                                WHERE  upper(hazard_class) = upper(p_hazrdmatl);
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        IF (l_Debug_Level <= 1) THEN
                                                itg_debug_pub.Add('SI - No hazard class ID found',1);
                                        END IF;

                                        itg_msg.no_hazard_class(p_hazrdmatl);
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
                END IF;

                IF (p_commodity1 is null and p_commodity2 is not null)
                or (p_commodity2 is null and p_commodity1 is not null) THEN
                        itg_msg.item_commodity_ign;
                -- continue processing.
                END IF;

                l_create_date    := NVL(p_create_date, SYSDATE);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('SI - Calling Get_ProcessSetId', 1);
                END IF;

                -- commented call to ITG_BatchManagement_PVT.Get_ProcessSetId
                l_set_process_id := Get_NextProcessSetId;
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('l_set_process_id' ||l_set_process_id, 1);
                        itg_debug_pub.Add( 'Inserting into mtl_system_items_interface',1);
                END IF;

                g_action := 'Item-interface insert';

                INSERT INTO mtl_system_items_interface (
                        set_process_id,
                        creation_date,
                        last_update_date,
                        last_updated_by,
                        hazard_class_id,
                        transaction_type,
                        process_flag,
                        primary_uom_code,
                        description,
                        segment1,
                        segment2,
                        segment3,
                        segment4,
                        segment5,
                        segment6,
                        segment7,
                        segment8,
                        segment9,
                        segment10,
                        segment11,
                        segment12,
                        segment13,
                        segment14,
                        segment15,
                        segment16,
                        segment17,
                        segment18,
                        segment19,
                        segment20,
                        organization_id,
                        inventory_item_status_code,
                        template_id,
                        receiving_routing_id,
                        item_type
                ) VALUES (
                        l_set_process_id,
                        l_create_date,
                        l_create_date,
                        FND_GLOBAL.user_id,
                        l_hazard_class_id,
                        DECODE(l_syncind, 'A','CREATE', 'C','UPDATE'),
                        1,
                        UPPER(p_uom),
                        p_itemdesc,
                        l_itemarray(1),
                        l_itemarray(2),
                        l_itemarray(3),
                        l_itemarray(4),
                        l_itemarray(5),
                        l_itemarray(6),
                        l_itemarray(7),
                        l_itemarray(8),
                        l_itemarray(9),
                        l_itemarray(10),
                        l_itemarray(11),
                        l_itemarray(12),
                        l_itemarray(13),
                        l_itemarray(14),
                        l_itemarray(15),
                        l_itemarray(16),
                        l_itemarray(17),
                        l_itemarray(18),
                        l_itemarray(19),
                        l_itemarray(20),
                        p_org_id,
                        p_itemstatus,
                        p_itemtype,
                        p_rctrout,
                        NULL
                ) RETURNING rowid INTO l_sii_rowid;

                g_action := 'Item-categories interface insert';

                IF p_commodity1 IS NOT NULL AND
                   p_commodity2 IS NOT NULL THEN

                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('SI - Inserting into mtl_items_categories_interface', 1);
                        END IF;

                        INSERT INTO mtl_item_categories_interface(
                                set_process_id,
                                item_number,
                                creation_date,
                                last_update_date,
                                last_updated_by,
                                organization_id,
                                transaction_type,
                                category_name,
                                category_set_name,
                                process_flag
                        ) VALUES  (
                                l_set_process_id,
                                p_item,
                                l_create_date,
                                l_create_date,
                                FND_GLOBAL.user_id,
                                p_org_id,
                                'CREATE',
                                p_commodity1,
                                p_commodity2,
                                1
                        )RETURNING rowid INTO l_ici_rowid;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('Committing item interfaces insert.', 1);
                END IF;
                COMMIT;

                -- comment call to ITG_BatchManagement_PVT.Added_RequestItem
                -- move code from Batch mgmt to here ..
                g_action := 'Item import program execution';
                l_ccm_request_id:= Start_BatchProcess(l_set_process_id,l_syncind,p_org_id);
                COMMIT;



                IF l_ccm_request_id <= 0 THEN
                        itg_msg.inv_cp_fail('NONE','NONE');
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                -- This was pulled from the original sync item code
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add( 'Waiting for concurrent request.', 1);
                        itg_debug_pub.Add( 'l_ccm_request_id'||l_ccm_request_id,1);
                END IF;

                l_bool := FND_CONCURRENT.wait_for_request(l_ccm_request_id, 30, 600,
                l_phase, l_status, l_dev_phase, l_dev_status, l_errmsg);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add( 'Results from concurrent request.', 1);
                        itg_debug_pub.Add( 'l_phase'    ||l_phase,1);
                        itg_debug_pub.Add( 'l_status'   ||l_status,1);
                        itg_debug_pub.Add( 'l_dev_phase'||l_dev_phase,1);
                        itg_debug_pub.Add( 'l_dev_status'||l_dev_status,1);
                        itg_debug_pub.Add( 'l_errmsg'   ||l_errmsg,1);
                END IF;

                l_reap_status := FND_API.G_RET_STS_SUCCESS;

                -- concurrent program has not completed
                -- error the collaboration, loggin ccm_id to the
                -- TODO: What are all the statuses and how do we react.
                IF upper(l_dev_phase) <>  'COMPLETE' THEN
                        itg_msg.item_import_pending(l_ccm_request_id, l_dev_status, l_dev_phase);
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF upper(l_dev_status) <> 'NORMAL' THEN
                        itg_msg.inv_cp_fail(l_dev_status,l_dev_phase);
                        -- do,not raise exception, try to move ahead and find error records
                END IF;

                IF l_bool THEN
                        l_reap_status := Reap_BatchResults(l_ccm_request_id,l_sii_rowid,l_ici_rowid);
                ELSE
                        g_action := 'Item import program status-retrival';
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF l_reap_status   <> FND_API.G_RET_STS_SUCCESS THEN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('SI - failure in Items Import concurrent request',1);
                        END IF;

                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('Committing work.',1);
                END IF;
                COMMIT;

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('--- Exiting Sync_Item ---',2);
                END IF;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        ROLLBACK;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        ITG_msg.checked_error(g_action);
                        IF (l_Debug_Level <= 6) THEN
                                itg_debug_pub.Add('--- Exiting Sync_Item ---ERROR',6);
                        END IF;

                WHEN OTHERS THEN
                        ROLLBACK;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        ITG_Debug.msg('Unexpected error (Exchange-rate sync) - ' || substr(SQLERRM,1,255),true);
                        ITG_msg.unexpected_error(g_action);
                        IF (l_Debug_Level <= 6) THEN
                                itg_debug_pub.Add('--- Exiting Sync_Item ---OTHER ERROR',6);
                        END IF;
        END;
    -- Removed FND_MSG_PUB.Count_And_Get
  END Sync_Item;


  FUNCTION Get_NextProcessSetId RETURN NUMBER IS
        l_process_set_id NUMBER;
  BEGIN
        SELECT mtl_system_items_intf_sets_s.nextval
        INTO   l_process_set_id
        FROM   dual;
        RETURN l_process_set_id;
  END Get_NextProcessSetId;



  /* Returns CCM request id. */
  -- decode syncind, set org conbtext
  FUNCTION Start_BatchProcess(
        p_process_set_id        NUMBER,
        p_syncind               VARCHAR2,
        p_org_id                VARCHAR2
  ) RETURN NUMBER IS
        l_upd_flag              NUMBER;
  BEGIN
        -- removed call to get process set info
        -- get the parameters directly
        -- removed call to batch mgmt.

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering Start_BatchProcess ---',2);
        END IF;

        IF p_syncind = 'A' THEN
                l_upd_flag := 1;
        ELSE
                l_upd_flag := 2;
        END IF;

        BEGIN
                FND_Client_Info.set_org_context(p_org_id);
                MO_GLOBAL.set_policy_context('S', p_org_id); -- MOAC
        EXCEPTION
                WHEN OTHERS THEN
                        ITG_Debug.add_exc_error(G_PKG_NAME, 'Start_BatchProcess');
                        itg_msg.invalid_org(p_org_id);
                        RAISE FND_API.G_EXC_ERROR;
        END;

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Exting Start_BatchProcess ---',2);
        END IF;

        RETURN FND_REQUEST.submit_request(
                        application => 'INV',
                        program     => 'INCOIN',
                        argument1   => p_org_id,          /* org_id */
                        argument2   => 2,                 /* all_org (1 = all, 2 = org_id) */
                        argument3   => 1,                 /* val_item_flag */
                        argument4   => 1,                 /* pro_item_flag */
                        argument5   => 2,                 /* del_rec_flag */
                        argument6   => p_process_set_id,  /* process_set */
                        argument7   => l_upd_flag         /* create_update (1 = cr, 2 = up) */
               );
  END Start_BatchProcess;


 --Assuming following process_flag
 --Tested with INV:Txn processing mode as immediate
 --Need to test with other modes
 --     > import pending (1,2)
 --     > import success (6,7)
 --     > import failure (3,4,5?)
 FUNCTION Reap_BatchResults(
        p_request_id            NUMBER,
        p_msii_rid              ROWID,
        p_mici_rid              ROWID) RETURN VARCHAR2 IS
        l_process_flag          VARCHAR2(30);
 BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering Reap_BatchResults ---',2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add( 'p_request_id' ||p_request_id ,1);
                itg_debug_pub.Add( 'p_msii_rid'   ||p_msii_rid,1);
                itg_debug_pub.Add( 'p_mici_rid'   ||p_mici_rid,1);
        END IF;

        BEGIN
                SELECT  process_flag
                INTO  l_process_flag
                FROM  mtl_system_items_interface
                WHERE rowid = p_msii_rid;
        EXCEPTION
                WHEN OTHERS THEN
                     l_process_flag  := null;
        END;

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('process_flag '||l_process_flag ,1);
        END IF;

        -- if item procssing not complete, log appropriate message and return
        IF l_process_flag IN ('1','2') THEN
                itg_msg.item_import_pending(p_request_id,null,null);
                return FND_API.G_RET_STS_ERROR;
        END IF;

        IF l_process_flag NOT IN ('6','7') OR l_process_flag IS NULL THEN
                ITG_Debug.msg('Item-import errored out, request-id:' || p_request_id,TRUE);
                itg_msg.item_import_errors;
                error_transactions(p_request_id,'MTL_SYSTEM_ITEMS_INTERFACE');
                return FND_API.G_RET_STS_ERROR;
        END IF;

        IF p_mici_rid IS NOT NULL THEN
                BEGIN
                        SELECT  process_flag
                        INTO            l_process_flag
                        FROM    mtl_item_categories_interface
                        WHERE   rowid = p_mici_rid;
                EXCEPTION
                        WHEN OTHERS THEN
                                l_process_flag  := null;
                END;

                -- if item category procssing not complete, log appropriate message and return
                -- since item interface import is success, make the txn/collaboration succesful
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('process_flag' || l_process_flag ,1);
                END IF;

                IF l_process_flag IN ('1','2') THEN
                        itg_msg.itemcat_import_pending(p_request_id);
                      return FND_API.G_RET_STS_SUCCESS;
                END IF;

                IF l_process_flag NOT IN ('6','7') OR l_process_flag IS NULL THEN
                        ITG_Debug.msg('Item-category import errored out, request-id:' || p_request_id,TRUE);
                        itg_msg.mici_only_failed;
                        error_transactions(p_request_id,'MTL_ITEM_CATEGORIES_INTERFACE');
                      return FND_API.G_RET_STS_SUCCESS;
                END IF;
        END IF;
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Exting Reap_BatchResults ---',2);
        END IF;
        -- code reaches here iff both item and category import are success
        return FND_API.G_RET_STS_SUCCESS;
  END;

 --TODO: What are the process_flag values for
 --     > Is txn id always returned??
 --     > Should we use request-id, table name combination instead?
 --     > import failure
 --     > message_name is it directly translatable?
  PROCEDURE error_transactions(
        p_request_id    VARCHAR2,
        p_table_name    VARCHAR2
  )
  IS
        CURSOR error_messages(p_request_id VARCHAR2,p_table_name VARCHAR2)
        IS
                SELECT  message_name, substr(error_message,1,2000)
                FROM    mtl_interface_errors
                WHERE   request_id = p_request_id
                AND   upper(table_name) = upper(p_table_name);

        l_err_msg       VARCHAR2(4000);
        l_msg_name  VARCHAR2(100);
  BEGIN

         IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('--- Entering error_transactions ---',2);
         END IF;

         select count(*) into l_err_msg
         from mtl_interface_errors
         where request_id = p_request_id and
               upper(table_name) = upper(p_table_name);

         OPEN error_messages(p_request_id,p_table_name);

         LOOP
                FETCH error_messages INTO l_msg_name, l_err_msg;
                EXIT WHEN error_messages%NOTFOUND;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('Found an error record' ,1);
                        itg_debug_pub.Add('l_msg_name' || l_msg_name ,1);
                        itg_debug_pub.Add('l_err_msg ' || l_err_msg ,1);
                END IF;

                IF l_err_msg IS NOT NULL THEN
                        itg_debug.msg(l_err_msg, TRUE);
                END IF;

                IF l_msg_name IS NOT NULL AND
                   length(itg_x_utils.getCBODDescMsg) < 1000 THEN
                        itg_x_utils.addCBODDescMsg(
                              p_msg_app => 'INV',
                              p_msg_code     => l_msg_name,
                              p_token_vals   => null,
                              p_translatable => TRUE,
                              p_reset        => FALSE
                        );
                END IF;
         END LOOP;
         IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('--- Exiting error_transactions ---',2);
         END IF;
        /* no value in doing this, this table can be purged periodically */
        --DELETE FROM mtl_interface_errors
      --WHERE  request_id = p_request_id

EXCEPTION
        WHEN OTHERS THEN
             itg_debug.msg('Error retrieving errors in item-import',TRUE);
             IF (l_Debug_Level <= 6) THEN
                    itg_debug_pub.Add('--- Exiting error_transactions ---OTHER ERROR',6);
             END IF;
                -- No value in propogating execption
END;

END ITG_SyncItemInbound_PVT;

/
