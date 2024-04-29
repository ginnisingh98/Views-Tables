--------------------------------------------------------
--  DDL for Package Body INV_WIP_PICKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_WIP_PICKING_PVT" AS
  /* $Header: INVVWPKB.pls 120.10.12010000.3 2009/02/11 02:13:18 mchemban ship $ */

  -- Conc mode identification
  g_conc_mode BOOLEAN := FALSE;
  g_trace_on NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),2);

  -- Allocation Status - Used both at Header Level (Pick_Release) and Lines Level (Process_Line)
  g_completely_allocated VARCHAR2(1) := 'S';
  g_partially_allocated  VARCHAR2(1) := 'P';
  g_not_allocated        VARCHAR2(1) := 'N';

  -- Global table to store allocation status at the move order line level
  TYPE g_mo_line_stat_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  g_mo_line_stat_tbl g_mo_line_stat_type;

  -- Bug 5469486: add a separate counter for lines where MO line not created
  g_mol_fail_count       NUMBER;

  -- Global variable for tracking WIP patch level
  -- Bug 4288399, moved to spec
  --g_wip_patch_level NUMBER := -999;

  -- Forward declarations
  PROCEDURE process_line(
    p_mo_line_rec        IN OUT NOCOPY inv_move_order_pub.trolin_rec_type
  , p_allow_partial_pick IN     VARCHAR2  DEFAULT  fnd_api.g_true
  , p_grouping_rule_id   IN     NUMBER    DEFAULT  NULL
  , p_plan_tasks         IN     BOOLEAN
  , p_call_wip_api       IN     BOOLEAN   --Added bug 4634522
  , x_return_status      OUT    NOCOPY  VARCHAR2
  , x_msg_count          OUT    NOCOPY  NUMBER
  , x_msg_data           OUT    NOCOPY  VARCHAR2
  , x_detail_rec_count   OUT    NOCOPY  NUMBER
  );

  PROCEDURE update_mmtt_for_wip(
    x_return_status    OUT NOCOPY VARCHAR2
  , p_mo_line_rec      IN         inv_move_order_pub.trolin_rec_type
  , p_grouping_rule_id IN         NUMBER
  );

  FUNCTION get_mo_alloc_stat RETURN VARCHAR2;
  -- End forward declarations

  PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
  BEGIN
    inv_log_util.trace(p_message, g_pkg_name || '.' || p_module,3);
  END print_debug;


  --
  -- pre patchset I version
  --
  PROCEDURE release_pick_batch
  ( p_mo_header_rec           IN   INV_Move_Order_PUB.Trohdr_Rec_Type
  , p_mo_line_rec_tbl         IN   INV_Move_Order_PUB.Trolin_Tbl_Type
  , p_auto_detail_flag        IN   VARCHAR2
  , p_auto_pick_confirm_flag  IN   VARCHAR2
  , p_allow_partial_pick      IN   VARCHAR2
  , p_commit                  IN   VARCHAR2
  , p_init_msg_lst            IN   VARCHAR2
  , x_return_status           OUT  NOCOPY  VARCHAR2
  , x_msg_count               OUT  NOCOPY  NUMBER
  , x_msg_data                OUT  NOCOPY  VARCHAR2
  ) IS

    l_conc_req_id        NUMBER;
    l_api_return_status  VARCHAR2(1);
    l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_mo_header_rec      INV_Move_Order_PUB.Trohdr_Rec_Type;

-- Bug 4288399
    l_wip_error_table    INV_WIP_Picking_PVT.Trolin_ErrTbl_Type;

  BEGIN
    IF (l_debug = 1) THEN
       print_debug('Pre-I version of pick release called', 'RELEASE_PICK_BATCH');
    END IF;

    g_wip_patch_level := 1158;
    l_mo_header_rec   := p_mo_header_rec;

    --
    -- Pre 11.5.9 WIP uses 2 move order types (G_MOVE_ORDER_WIP_ISSUE and G_MOVE_ORDER_BACKFLUSH),
    -- but Inventory 11.5.9 has changed to a single type (G_MOVE_ORDER_MFG_PICK)
    --
    IF l_mo_header_rec.move_order_type = INV_GLOBALS.G_MOVE_ORDER_BACKFLUSH THEN
       l_mo_header_rec.move_order_type := INV_GLOBALS.G_MOVE_ORDER_MFG_PICK;
       IF (l_debug = 1) THEN
          print_debug('Changed MO type from ' || INV_GLOBALS.G_MOVE_ORDER_BACKFLUSH ||' to ' || l_mo_header_rec.move_order_type, 'RELEASE_PICK_BATCH');
       END IF;
    END IF;

    release_pick_batch(
      p_mo_header_rec           => l_mo_header_rec
    , p_mo_line_rec_tbl         => p_mo_line_rec_tbl
    , p_auto_detail_flag        => p_auto_detail_flag
    , p_auto_pick_confirm_flag  => p_auto_pick_confirm_flag
    , p_allow_partial_pick      => p_allow_partial_pick
    , p_print_pick_slip         => FND_API.G_FALSE
    , p_plan_tasks              => FALSE
    , p_commit                  => p_commit
    , p_init_msg_lst            => p_init_msg_lst
    , x_return_status           => l_api_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , x_conc_req_id             => l_conc_req_id
    , x_mo_line_errrec_tbl      => l_wip_error_table -- Bug 4288399
    );

    IF (l_debug = 1) THEN
      print_debug('Return Status from release_pick_batch (main): ' || l_api_return_status, 'RELEASE_PICK_BATCH');
    END IF;

    --
    -- Pre 11.5.9 WIP code does not recognize status 'N'
    --
    IF l_api_return_status = 'N' THEN
       l_api_return_status := 'P';
    END IF;

    x_return_status := l_api_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('Error: ' || SQLCODE || ', ' || SQLERRM, 'RELEASE_PICK_BATCH');
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
  END release_pick_batch;



  --
  -- patchset I version
  --
  PROCEDURE release_pick_batch
  ( p_mo_header_rec           IN OUT NOCOPY inv_move_order_pub.trohdr_rec_type
  , p_mo_line_rec_tbl         IN     inv_move_order_pub.trolin_tbl_type
  , p_auto_detail_flag        IN     VARCHAR2
  , p_auto_pick_confirm_flag  IN     VARCHAR2
  , p_allow_partial_pick      IN     VARCHAR2
  , p_print_pick_slip         IN     VARCHAR2
  , p_plan_tasks              IN     BOOLEAN
  , p_commit                  IN     VARCHAR2
  , p_init_msg_lst            IN     VARCHAR2
  , x_return_status           OUT    NOCOPY  VARCHAR2
  , x_msg_count               OUT    NOCOPY  NUMBER
  , x_msg_data                OUT    NOCOPY  VARCHAR2
  , x_conc_req_id             OUT    NOCOPY  NUMBER
  , x_mo_line_errrec_tbl      OUT    NOCOPY  INV_WIP_Picking_PVT.Trolin_ErrTbl_Type  -- Bug 4288399
  ) IS

    l_api_version_number    NUMBER       := 1.0;
    l_api_return_status     VARCHAR2(1);
    l_commit                VARCHAR2(1)  := fnd_api.g_false;
    l_temp                  BOOLEAN;
    l_trohdr_val_rec        inv_move_order_pub.trohdr_val_rec_type;
    l_trolin_val_tbl        inv_move_order_pub.trolin_val_tbl_type;
    l_organization_id       NUMBER;
    l_auto_pick_confirm     VARCHAR2(1)  := fnd_api.g_false;
    l_entity_type           NUMBER;
    l_max_batch             NUMBER;
    l_counter               NUMBER;
    l_last_rec              NUMBER;
    l_last_batch_rec        NUMBER;
    l_rec_count             NUMBER;
    l_index                 NUMBER;
    l_line_tbl              inv_move_order_pub.trolin_tbl_type;
    l_is_wms_org            BOOLEAN  := FALSE;
    l_mo_allocation_status  VARCHAR2(1) := g_not_allocated;
    l_req_msg               VARCHAR2(255); -- Informational message from device integration API

-- Bug 4288399
    l_wip_error_table       INV_WIP_Picking_PVT.Trolin_ErrTbl_Type;
    l_wip_error_table_cnt   NUMBER := 0;
    l_msgcnt                NUMBER;
    l_msg_data              VARCHAR2(2000);

    l_savept_exists         BOOLEAN := FALSE;
    l_wip_err_count         NUMBER;
    l_err_start_index       NUMBER;

    CURSOR c_get_entity_type(p_wip_entity_id IN NUMBER, p_org_id IN NUMBER) IS
        SELECT entity_type
          FROM wip_entities
         WHERE wip_entity_id   = p_wip_entity_id
           AND organization_id = p_org_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN

    IF NVL(g_wip_patch_level,-999) = -999 THEN
       g_wip_patch_level := 1159;
    END IF;

    l_organization_id  := p_mo_header_rec.organization_id;
    IF (l_debug = 1) THEN
       print_debug('***************** Start of WIP pick release ****************', 'RELEASE_PICK_BATCH');
       print_debug('Org ID: '|| TO_CHAR(l_organization_id), 'RELEASE_PICK_BATCH');
    END IF;
    g_mo_line_stat_tbl.DELETE;
    g_mol_fail_count := 0;

    SAVEPOINT inv_wip_pick_release;
    l_savept_exists := TRUE;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    -- Validate parameter for allowing partial pick release
    IF  p_allow_partial_pick NOT IN (fnd_api.g_true, fnd_api.g_false) THEN
       IF (l_debug = 1) THEN
          print_debug('Error: invalid partial pick parameter','RELEASE_PICK_BATCH');
       END IF;
       fnd_message.set_name('INV', 'INV_INVALID_PARTIAL_PICK_PARAM');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('p_allow_partial_pick is '|| p_allow_partial_pick, 'RELEASE_PICK_BATCH');
    END IF;

    --Bug 4288399, if its not a concurrent mode, the profile is set to -1
    --so, changed the check below from 0 to -1
    IF NVL(fnd_profile.VALUE('CONC_REQUEST_ID'), -1) <> -1 THEN
       g_conc_mode  := TRUE;
    ELSE
       g_conc_mode  := FALSE;
    END IF;

    l_is_wms_org := inv_install.adv_inv_installed(l_organization_id);

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Determine whether or not to automatically pick confirm
    IF p_auto_pick_confirm_flag <> fnd_api.g_miss_char THEN
       IF (p_auto_pick_confirm_flag NOT IN  (fnd_api.g_true, fnd_api.g_false) ) THEN
          IF (l_debug = 1) THEN
             print_debug('Error: Invalid auto_pick_confirm flag', 'RELEASE_PICK_BATCH');
          END IF;
          fnd_message.set_name('INV', 'INV_AUTO_PICK_CONFIRM_PARAM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
       ELSE
          l_auto_pick_confirm  := p_auto_pick_confirm_flag;
       END IF;
    ELSE
       -- Retrieve the org-level parameter for auto-pick confirm
       BEGIN
          -- The parameter is for whether pick confirm is required or not,
          -- so the auto-pick confirm flag is the opposite of this.
          SELECT DECODE(NVL(mo_pick_confirm_required, 2), 1, fnd_api.g_false, 2, fnd_api.g_true, fnd_api.g_true)
            INTO l_auto_pick_confirm
            FROM mtl_parameters
           WHERE organization_id = l_organization_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                  print_debug('Error: Invalid auto_pick_confirm flag', 'RELEASE_PICK_BATCH');
              END IF;
              fnd_message.set_name('INV', 'INV-NO ORG INFORMATION');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
       END;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('Auto Pick Confirm flag: '|| l_auto_pick_confirm, 'RELEASE_PICK_BATCH');
    END IF;

    -- Bug 2666620: Grouping Rule ID has to be stamped
    -- Bug 2844622: Skip this check if WIP patch level is below 11.5.9
    IF g_wip_patch_level >= 1159 THEN
       IF nvl(p_mo_header_rec.grouping_rule_id,fnd_api.g_miss_num) =  fnd_api.g_miss_num THEN
          IF (l_debug = 1) THEN
             print_debug('No Pick Slip Grouping Rule ID specified', 'RELEASE_PICK_BATCH');
          END IF;
          fnd_message.set_name('INV', 'INV_NO_PICK_SLIP_NUMBER');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    ELSE
       IF (l_debug = 1) THEN
          print_debug('WIP patch level is ' || to_char(g_wip_patch_level) ||
                      ' so skipping grouping_rule_id check.', 'RELEASE_PICK_BATCH');
       END IF;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('Calling Create Move Order Header', 'RELEASE_PICK_BATCH');
    END IF;

    inv_move_order_pub.create_move_order_header(
      p_api_version_number  => l_api_version_number
    , p_init_msg_list       => fnd_api.g_false
    , p_return_values       => fnd_api.g_true
    , p_commit              => l_commit
    , x_return_status       => l_api_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
    , p_trohdr_rec          => p_mo_header_rec
    , p_trohdr_val_rec      => l_trohdr_val_rec
    , x_trohdr_rec          => p_mo_header_rec
    , x_trohdr_val_rec      => l_trohdr_val_rec
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF (l_debug = 1) THEN
          print_debug('Error occurred in Create_Move_Order_Header', 'RELEASE_PICK_BATCH');
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    ELSE
       IF (l_debug = 1) THEN
          print_debug('Created MO Header successfully: '|| p_mo_header_rec.header_id, 'RELEASE_PICK_BATCH');
       END IF;
    END IF;

    IF p_mo_line_rec_tbl.COUNT > 0 THEN
       IF (l_debug = 1) THEN
          print_debug('Number of MO Lines to create: '|| TO_CHAR(p_mo_line_rec_tbl.COUNT), 'RELEASE_PICK_BATCH');
       END IF;
    ELSE
       IF (l_debug = 1) THEN
          print_debug('No MO Lines to create!', 'RELEASE_PICK_BATCH');
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Bug 2844622: Skip performance changes (breaking up move order lines
    -- into batches) if WIP patch level is below 11.5.9
    --
    IF g_wip_patch_level >= 1159 THEN
       l_max_batch := to_number(fnd_profile.value('INV_COMPONENT_PICK_BATCH_SIZE'));
       IF (l_debug = 1) THEN
          print_debug('Max batch size: ' || l_max_batch, 'RELEASE_PICK_BATCH');
       END IF;
       IF l_max_batch IS NULL or l_max_batch <= 0 THEN
          l_max_batch := 20;
          IF (l_debug = 1) THEN
             print_debug('using default batch size of 20', 'RELEASE_PICK_BATCH');
          END IF;
       END IF;

       l_last_rec := p_mo_line_rec_tbl.LAST;
       l_counter  := p_mo_line_rec_tbl.FIRST;
       WHILE l_counter <= l_last_rec LOOP
         IF (l_debug = 1) THEN
             print_debug('Rec Counter: ' || l_counter, 'RELEASE_PICK_BATCH');
         END IF;
         l_last_batch_rec := l_counter + l_max_batch-1;
         IF l_last_batch_rec >= l_last_rec THEN
            l_last_batch_rec := l_last_rec;
            -- find the end of the current ship set.  All the lines for this
            -- shipset should be processed in the same commit cycle
         ELSIF p_mo_line_rec_tbl(l_last_batch_rec).ship_set_id IS NOT NULL THEN
            LOOP
               EXIT WHEN l_last_batch_rec = l_last_rec;

               IF p_mo_line_rec_tbl(l_last_batch_rec+1).ship_set_id IS NULL
                  OR (p_mo_line_rec_tbl(l_last_batch_rec).ship_set_id
                      <> p_mo_line_rec_tbl(l_last_batch_rec+1).ship_set_id)
               THEN
                  -- last_batch_rec is the last line in this shipset, so exit
                  EXIT;
               END IF;

               l_last_batch_rec := l_last_batch_rec + 1;
            END LOOP;
         END IF;

         IF (l_debug = 1) THEN
            print_debug('Last batch record:'||l_last_batch_rec, 'RELEASE_PICK_BATCH');
         END IF;

         --copy move order lines into table to pass to create MO lines and pick release;
         l_rec_count := l_counter;
         l_index := 1;
         LOOP
            EXIT WHEN l_rec_count > l_last_batch_rec;
            l_line_tbl(l_index) := p_mo_line_rec_tbl(l_rec_count);
            l_line_tbl(l_index).header_id := p_mo_header_rec.header_id;
            l_line_tbl(l_index).line_number := l_rec_count;
            l_index := l_index + 1;
            l_rec_count:= l_rec_count + 1;
         END LOOP;

         IF (l_debug = 1) THEN
            print_debug('Calling create_move_order_lines', 'RELEASE_PICK_BATCH');
         END IF;

         IF NOT l_savept_exists THEN
            SAVEPOINT inv_wip_pick_release;
            l_savept_exists := TRUE;
         END IF;

         inv_move_order_pub.create_move_order_lines(
           p_api_version_number  => l_api_version_number
         , p_init_msg_list       => fnd_api.g_true
         , p_return_values       => fnd_api.g_true
         , p_commit              => l_commit
         , x_return_status       => l_api_return_status
         , x_msg_count           => x_msg_count
         , x_msg_data            => x_msg_data
         , p_trolin_tbl          => l_line_tbl
         , p_trolin_val_tbl      => l_trolin_val_tbl
         , x_trolin_tbl          => l_line_tbl
         , x_trolin_val_tbl      => l_trolin_val_tbl
         );

         IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
            IF (l_debug = 1) THEN
               print_debug('Error occurred in Create_Move_Order_Lines = '||l_api_return_status
                          ,'RELEASE_PICK_BATCH');
            END IF;
         -- Bug 4288399, Filtering the errored records and continuing
            IF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF (g_conc_mode) THEN
               l_wip_err_count := 0;
               l_err_start_index := l_wip_error_table.COUNT;
               IF (l_debug = 1) THEN
                  print_debug('Conc_mode is True', 'RELEASE_PICK_BATCH');
                  print_debug('Number of records currently in error table: ' || l_err_start_index,
                              'RELEASE_PICK_BATCH');
               END IF;
               FOR i in 1..l_line_tbl.COUNT LOOP
                 IF l_line_tbl(i).return_status = fnd_api.g_ret_sts_error THEN
                    IF (l_debug = 1) THEN
                       print_debug('Delete Line '||l_line_tbl(i).line_id, 'RELEASE_PICK_BATCH');
                    END IF;

                    -- Bug 5469486: handle the case where line ID is g_miss_num
                    IF l_line_tbl(i).line_id = fnd_api.g_miss_num THEN
                       g_mol_fail_count := g_mol_fail_count + 1;
                    ELSE
                       g_mo_line_stat_tbl(l_line_tbl(i).line_id) := g_not_allocated;
                    END IF;

                    l_wip_error_table_cnt := l_wip_error_table.COUNT + 1;
                    l_wip_err_count := l_wip_err_count + 1;
                    l_wip_error_table(l_wip_error_table_cnt).line_id := l_line_tbl(i).line_id;
                    l_wip_error_table(l_wip_error_table_cnt).header_id  := l_line_tbl(i).header_id;
                    l_wip_error_table(l_wip_error_table_cnt).organization_id  := l_line_tbl(i).organization_id;
                    l_wip_error_table(l_wip_error_table_cnt).inventory_item_id  := l_line_tbl(i).inventory_item_id;
                    l_wip_error_table(l_wip_error_table_cnt).txn_source_id := l_line_tbl(i).txn_source_id;
                    l_wip_error_table(l_wip_error_table_cnt).txn_source_line_id := l_line_tbl(i).txn_source_line_id;
                    l_wip_error_table(l_wip_error_table_cnt).from_subinventory_code := l_line_tbl(i).from_subinventory_code;
                    l_wip_error_table(l_wip_error_table_cnt).to_subinventory_code := l_line_tbl(i).to_subinventory_code;
                    l_wip_error_table(l_wip_error_table_cnt).line_status  := l_line_tbl(i).line_status;
                    l_wip_error_table(l_wip_error_table_cnt).lot_number  := l_line_tbl(i).lot_number;
                    l_wip_error_table(l_wip_error_table_cnt).from_locator_id  := l_line_tbl(i).from_locator_id;
                    l_wip_error_table(l_wip_error_table_cnt).to_locator_id  := l_line_tbl(i).to_locator_id;
                    l_wip_error_table(l_wip_error_table_cnt).project_id  := l_line_tbl(i).project_id;
                    l_wip_error_table(l_wip_error_table_cnt).task_id  := l_line_tbl(i).task_id;
                    l_wip_error_table(l_wip_error_table_cnt).revision  := l_line_tbl(i).revision;
                    l_wip_error_table(l_wip_error_table_cnt).transaction_type_id  := l_line_tbl(i).transaction_type_id;
                    l_wip_error_table(l_wip_error_table_cnt).primary_quantity  :=   l_line_tbl(i).primary_quantity;
                    l_wip_error_table(l_wip_error_table_cnt).to_organization_id  :=   l_line_tbl(i).to_organization_id;
                    l_wip_error_table(l_wip_error_table_cnt).uom_code  :=   l_line_tbl(i).uom_code;
                    l_wip_error_table(l_wip_error_table_cnt).lpn_id  :=   l_line_tbl(i).lpn_id;
                    l_wip_error_table(l_wip_error_table_cnt).to_lpn_id  :=   l_line_tbl(i).to_lpn_id;
                    l_wip_error_table(l_wip_error_table_cnt).return_status  :=   l_line_tbl(i).return_status;
                    l_wip_error_table(l_wip_error_table_cnt).ship_set_id  :=   l_line_tbl(i).ship_set_id;
                    l_wip_error_table(l_wip_error_table_cnt).required_quantity  :=   l_line_tbl(i).required_quantity;
                    l_wip_error_table(l_wip_error_table_cnt).quantity   := l_line_tbl(i).quantity;
                    l_wip_error_table(l_wip_error_table_cnt).quantity_delivered   := l_line_tbl(i).quantity_delivered;
                    l_wip_error_table(l_wip_error_table_cnt).quantity_detailed   := l_line_tbl(i).quantity_detailed;
                    l_wip_error_table(l_wip_error_table_cnt).line_number   := l_line_tbl(i).line_number;
                    l_wip_error_table(l_wip_error_table_cnt).creation_date := l_line_tbl(i).creation_date;
                    l_wip_error_table(l_wip_error_table_cnt).date_required := l_line_tbl(i).date_required;
                    l_wip_error_table(l_wip_error_table_cnt).to_organization_id := l_line_tbl(i).to_organization_id;
                    l_wip_error_table(l_wip_error_table_cnt).ship_model_id := l_line_tbl(i).ship_model_id;
                    l_line_tbl.DELETE(i);
                    l_trolin_val_tbl.DELETE(i);
                 END IF;
               END LOOP;
               FND_MSG_PUB.Count_And_Get(p_encoded => 'T', p_count => l_msgcnt, p_data  => l_msg_data);
               IF (l_debug = 1) THEN
                  print_debug('Msg count: ' || l_msgcnt, 'RELEASE_PICK_BATCH');
                  print_debug('WIP err table count: ' || l_wip_error_table.count, 'RELEASE_PICK_BATCH');
               END IF;
               FOR  x IN 1..l_msgcnt LOOP
                   IF (l_debug = 1) THEN
                      print_debug('Msg number: ' || x, 'RELEASE_PICK_BATCH');
                   END IF;
                   l_msg_data  := fnd_msg_pub.get(x, 'F');
                   IF (l_debug = 1) THEN
                      print_debug('Error message: ' || l_msg_data, 'RELEASE_PICK_BATCH');
                   END IF;
                   IF (l_debug = 1) THEN
                      print_debug('  Errored Line Details wip_entity_id ='||l_wip_error_table(x).txn_source_id||
                                  ', operation_sec_num ='||l_wip_error_table(x).txn_source_line_id||
                                  ', inventory_item_id ='||l_wip_error_table(x).inventory_item_id,
                                  'RELEASE_PICK_BATCH');
                   END IF;
                   IF l_msgcnt = l_wip_err_count THEN
                      l_wip_error_table(l_err_start_index + x).error_message := l_msg_data;
                   END IF;
               END LOOP;
             ELSE
               IF (l_debug = 1) THEN
                  print_debug('Conc_mode is False', 'RELEASE_PICK_BATCH');
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         ELSE
            IF (l_debug = 1) THEN
               print_debug('Created MO Lines successfully', 'RELEASE_PICK_BATCH');
            END IF;
         END IF;

         IF (l_debug = 1) THEN
            print_debug('MO line creation complete, before calling pick release..',
                        'RELEASE_PICK_BATCH');
         END IF;

         IF p_auto_detail_flag = fnd_api.g_true AND l_line_tbl.COUNT > 0 THEN
            IF (l_debug = 1) THEN
               print_debug('Calling pick_release', 'RELEASE_PICK_BATCH');
            END IF;
            l_api_return_status := fnd_api.g_ret_sts_success;
            pick_release(
              x_return_status      => l_api_return_status
            , x_msg_count          => x_msg_count
            , x_msg_data           => x_msg_data
            , p_commit             => l_commit
            , p_init_msg_lst       => fnd_api.g_true
            , p_mo_line_tbl        => l_line_tbl
            , p_allow_partial_pick => p_allow_partial_pick
            , p_grouping_rule_id   => p_mo_header_rec.grouping_rule_id
            , p_plan_tasks         => p_plan_tasks
            , p_call_wip_api       => TRUE
            );

            IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
               IF (l_debug = 1) THEN
                  print_debug('Error occurred in Pick_Release', 'RELEASE_PICK_BATCH');
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF; -- end if auto detail flag is true

         COMMIT;
         l_savept_exists := FALSE;

         l_counter := l_last_batch_rec + 1;
         l_line_tbl.DELETE;
         inv_quantity_tree_pvt.clear_quantity_cache;
       END LOOP;
    ELSE
       -- WIP is 11.5.8 or lower
       l_line_tbl := p_mo_line_rec_tbl;

       FOR ii IN l_line_tbl.FIRST..l_line_tbl.LAST
       LOOP
           l_line_tbl(ii).header_id := p_mo_header_rec.header_id;
           l_line_tbl(ii).line_number := ii;
       END LOOP;

       inv_move_order_pub.create_move_order_lines(
         p_api_version_number  => l_api_version_number
       , p_init_msg_list       => fnd_api.g_false
       , p_return_values       => fnd_api.g_true
       , p_commit              => l_commit
       , x_return_status       => l_api_return_status
       , x_msg_count           => x_msg_count
       , x_msg_data            => x_msg_data
       , p_trolin_tbl          => l_line_tbl
       , p_trolin_val_tbl      => l_trolin_val_tbl
       , x_trolin_tbl          => l_line_tbl
       , x_trolin_val_tbl      => l_trolin_val_tbl
       );

       IF l_api_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          print_debug ('Error occurred in INV_Move_Order_PUB.Create_Move_Order_Lines', 'RELEASE_PICK_BATCH');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
          print_debug ('Created MO Lines successfully', 'RELEASE_PICK_BATCH');
       END IF;

       IF p_auto_detail_flag = FND_API.G_TRUE THEN
          pick_release(
            x_return_status       => l_api_return_status
          , x_msg_count           => x_msg_count
          , x_msg_data            => x_msg_data
          , p_commit              => l_commit
          , p_init_msg_lst        => fnd_api.g_false
          , p_mo_line_tbl         => l_line_tbl
          , p_allow_partial_pick  => p_allow_partial_pick
          , p_grouping_rule_id    => NULL
          , p_plan_tasks          => p_plan_tasks
          , p_call_wip_api        => TRUE
          );

          IF l_api_return_status <> FND_API.G_RET_STS_SUCCESS AND
             l_api_return_status <> 'P'  THEN
             print_debug ('Error occurred in Pick_Release', 'RELEASE_PICK_BATCH');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_api_return_status = 'P' THEN
             print_debug ('One or more lines failed to allocate fully', 'RELEASE_PICK_BATCH');
             x_return_status := 'P';
          ELSE
             print_debug ('Pick Release successful.', 'RELEASE_PICK_BATCH');
          END IF;
       END IF; -- end if auto detail flag is true
    END IF; -- end if wip patch level >= 1159

    l_mo_allocation_status := get_mo_alloc_stat();
    g_mo_line_stat_tbl.DELETE;
    g_mol_fail_count := 0;

    IF NOT l_savept_exists THEN
       SAVEPOINT inv_wip_pick_release;
       l_savept_exists := TRUE;
    END IF;

    -- Printing the Pick Slip
    IF p_print_pick_slip = FND_API.G_TRUE AND l_mo_allocation_status <> g_not_allocated THEN
       x_conc_req_id := inv_pr_pick_slip_number.print_pick_slip(
                          x_return_status      => l_api_return_status
                        , x_msg_data           => x_msg_data
                        , x_msg_count          => x_msg_count
                        , p_organization_id    => l_organization_id
                        , p_mo_request_number  => p_mo_header_rec.request_number
                        , p_plan_tasks         => p_plan_tasks
                        );

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF (l_debug = 1) THEN
             print_debug('Unable to submit Pick Slip Report Request','RELEASE_PICK_BATCH');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       IF (l_debug = 1) THEN
          print_debug('Pick Slip Report Request ID = ' || x_conc_req_id,'RELEASE_PICK_BATCH');
       END IF;
    END IF;

    -- Delete the pick slip number cache if WIP patch level is 11.5.9 or higher
    IF g_wip_patch_level >= 1159 THEN
       inv_pr_pick_slip_number.delete_wip_ps_tbl;
    END IF;

    IF l_is_wms_org THEN
      --
      -- Call Device Integration API to send the details of this
      -- Pick Release Wave to devices, based on configuration.
      -- All the Move Order Lines should have the same MO Header ID.
      -- So using the FIRST line's Header ID.
      -- Note: We don't check for the return condition of this API as
      -- we let the Pick Release process to complete whether or not
      -- Device Integration succeeds.
      --
      wms_device_integration_pvt.device_request(
        p_bus_event      => wms_device_integration_pvt.wms_be_pick_release
      , p_call_ctx       => wms_device_integration_pvt.dev_req_user
      , p_task_trx_id    => p_mo_header_rec.header_id
      , x_request_msg    => l_req_msg
      , x_return_status  => l_api_return_status
      , x_msg_count      => x_msg_count
      , x_msg_data       => x_msg_data
      );
      IF (l_debug = 1) THEN
         print_debug('Device_API Return Status = '|| l_api_return_status ||
                     ' : Request Msg = ' || l_req_msg, 'RELEASE_PICK_BATCH');
      END IF;
    END IF;

    -- Standard call to commit
    IF p_commit = fnd_api.g_true THEN
       COMMIT;
       l_savept_exists := FALSE;
    END IF;

    x_return_status := l_mo_allocation_status;

    -- Bug 4288399, returning the table of errored records back to the calling program.
    x_mo_line_errrec_tbl := l_wip_error_table;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
         print_debug ('Release_pick_batch Error: ' || SQLERRM, 'RELEASE_PICK_BATCH');
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      IF (l_savept_exists) THEN
         ROLLBACK TO inv_wip_pick_release;
      END IF;
      IF g_conc_mode THEN
        l_temp  := fnd_concurrent.set_completion_status('ERROR', '');
      END IF;
  END release_pick_batch;



  PROCEDURE pick_release(
    x_return_status       OUT  NOCOPY VARCHAR2
  , x_msg_count           OUT  NOCOPY NUMBER
  , x_msg_data            OUT  NOCOPY VARCHAR2
  , p_commit              IN   VARCHAR2
  , p_init_msg_lst        IN   VARCHAR2
  , p_mo_line_tbl         IN   inv_move_order_pub.trolin_tbl_type
  , p_allow_partial_pick  IN   VARCHAR2
  , p_grouping_rule_id    IN   NUMBER
  , p_plan_tasks          IN   BOOLEAN
  , p_call_wip_api        IN   BOOLEAN
  ) IS

    l_api_version_number     NUMBER   := 1.0;
    l_line_index             NUMBER; -- The index of the line in the table being processed
    l_mo_line                inv_move_order_pub.trolin_rec_type;
    l_organization_id        NUMBER; -- The OrgID to use (based on the MO Lines Passed in).
    l_mo_header_id           NUMBER; -- Move Order Header ID
    l_mo_type                NUMBER; -- The type of the move order (Should be only 5)
    l_mo_number              VARCHAR2(30); -- The move order number
    l_api_return_status      VARCHAR2(1);
    l_processed_row_count    NUMBER   := 0; -- The number of rows which have been processed.
    l_detail_rec_count       NUMBER   := 0;
    l_quantity               NUMBER;
    l_transaction_quantity   NUMBER;
    l_primary_quantity       NUMBER;
    l_wip_alloc_qty          NUMBER;
    l_line_status            NUMBER;
    l_disable_cartonization  VARCHAR2(1);
    l_wip_entity_name        VARCHAR2(240);
    l_item_number            VARCHAR2(40);

    -- Used for processing WIP pick sets (ship_set_id)
    l_cur_ship_set_id        NUMBER   := NULL;
    l_set_index              NUMBER;
    l_start_index            NUMBER;
    l_set_process            NUMBER;
    l_start_process          NUMBER;

    l_tree_id                NUMBER;
    l_revision_control_code  NUMBER;
    l_lot_control_code       NUMBER;

    l_is_wms_org             BOOLEAN  := FALSE;

    TYPE quantity_tree_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    l_quantity_tree_tbl      quantity_tree_tbl_type;
    l_qtree_backup_tbl       quantity_tree_tbl_type;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    -- Bug 4349602: save all MOL IDs in current batch
    TYPE l_molid_tbltyp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_mol_id_tbl                  l_molid_tbltyp;
    l_mol_id_index                NUMBER;

  BEGIN
    -- Set savepoint for this API
    IF (l_debug = 1) THEN
       print_debug('Inside Pick_Release', 'PICK_RELEASE');
    END IF;
    SAVEPOINT pick_release;
    -- Initialize API return status to success
    x_return_status    := fnd_api.g_ret_sts_success;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Added bug 4634522
    IF (WIP_CONSTANTS.DMF_PATCHSET_LEVEL = WIP_CONSTANTS.DMF_PATCHSET_I_VALUE) THEN
    	g_wip_patch_level := 1159;
    ELSIF (WIP_CONSTANTS.DMF_PATCHSET_LEVEL = WIP_CONSTANTS.DMF_PATCHSET_J_VALUE) THEN
      	g_wip_patch_level := 11510;
    END IF;
    --end of fix for  bug 4634522

    IF p_mo_line_tbl.COUNT = 0 THEN
      IF (l_debug = 1) THEN
         print_debug('No Lines to pick', 'PICK_RELEASE');
      END IF;
      fnd_message.set_name('INV', 'INV_NO_LINES_TO_PICK');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Bug 2038564: Clearing Qty Tree
    inv_quantity_tree_pvt.clear_quantity_cache;

    -- Validate that all move order lines are from the same org, that all lines
    -- have a status of pre-approved (7) or approved (3), and that all of the move
    -- order lines are of type Manufacturing Component Pick (5)
    l_line_index       := p_mo_line_tbl.FIRST;
    l_mol_id_index     := 1;
    l_organization_id  := p_mo_line_tbl(l_line_index).organization_id;
    l_is_wms_org       := inv_install.adv_inv_installed(l_organization_id);

    --Bug 4288399, Printing Org ID as l_organization_id
    IF (l_debug = 1) THEN
       print_debug('MO Line count = ' || p_mo_line_tbl.COUNT ||
                   ' : Org ID = '     || l_organization_id, 'PICK_RELEASE');
    END IF;

    -- Bug 2666620: Moved it outside of LOOP so that it is done only once.
    -- Verify that the move order type is of type Manufacturing Component Pick (5)
    BEGIN
       SELECT header_id, move_order_type, request_number
         INTO l_mo_header_id, l_mo_type, l_mo_number
        FROM mtl_txn_request_headers
       WHERE header_id = p_mo_line_tbl(l_line_index).header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
           print_debug('Error: Move Order Header not found', 'PICK_RELEASE');
        END IF;
        fnd_message.set_name('INV', 'INV_NO_HEADER_FOUND');
        fnd_message.set_token('MO_LINE_ID', TO_CHAR(p_mo_line_tbl(l_line_index).line_id));
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF l_mo_type <> inv_globals.g_move_order_mfg_pick THEN
      IF (l_debug = 1) THEN
         print_debug('Error: Trying to release non WIP move order', 'PICK_RELEASE');
      END IF;
      fnd_message.set_name('INV', 'INV_NOT_WIP_MOVE_ORDER');
      fnd_message.set_token('MO_NUMBER', l_mo_number);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    LOOP
      l_mo_line := p_mo_line_tbl(l_line_index);

      IF (l_mo_line.return_status NOT IN (fnd_api.g_ret_sts_unexp_error, fnd_api.g_ret_sts_error) ) THEN
        -- Verify that the lines are all for the same organization
        IF l_mo_line.organization_id <> l_organization_id THEN
          IF (l_debug = 1) THEN
             print_debug('Error: Trying to pick for different org', 'PICK_RELEASE');
          END IF;
          fnd_message.set_name('INV', 'INV_PICK_DIFFERENT_ORG');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Verify that the line status is approved or pre-approved
        IF (l_mo_line.line_status NOT IN (3,7)) THEN
          IF (l_debug = 1) THEN
             print_debug('Error: Invalid Move Order Line Status', 'PICK_RELEASE');
          END IF;
          fnd_message.set_name('INV', 'INV_PICK_LINE_STATUS');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Carton Grouping ID has to be stamped.
        -- Bug 2844622: Skip this check if WIP patch level is below 11.5.9
        IF g_wip_patch_level >= 1159 THEN
          IF (l_is_wms_org AND NVL(l_mo_line.carton_grouping_id, fnd_api.g_miss_num) = fnd_api.g_miss_num) THEN
            IF (l_debug = 1) THEN
               print_debug('Error: No Carton Grouping ID specified', 'PICK_RELEASE');
            END IF;
            fnd_message.set_name('WMS', 'WMS_NO_CARTON_GROUP_ID');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            print_debug('WIP Patch Level = ' || g_wip_patch_level ||' so skipping Carton Group ID check', 'PICK_RELEASE');
           END IF;
        END IF;
        -- Bug 2666620: End of Code Changes
        l_mol_id_tbl(l_mol_id_index) := l_mo_line.line_id;
        l_mol_id_index := l_mol_id_index + 1;
      END IF; -- end if MO line status is error

      -- We should create the quantity tree here so that we can
      -- a) lock the tree
      -- b) use the tree id to backup the quantity tree for ship
      --    set and ship model id;
      -- we only want to call create_tree once per org/item;
      -- This should not be a performance hit as long as ARU
      -- 1625268 has been applied.

      IF NOT (l_quantity_tree_tbl.EXISTS(l_mo_line.inventory_item_id)) THEN
        IF (l_debug = 1) THEN
           print_debug('Creating Qty Tree for Item '|| TO_CHAR(l_mo_line.inventory_item_id), 'PICK_RELEASE');
        END IF;

        BEGIN
          SELECT revision_qty_control_code, lot_control_code
            INTO l_revision_control_code, l_lot_control_code
            FROM mtl_system_items
           WHERE organization_id = l_organization_id
             AND inventory_item_id = l_mo_line.inventory_item_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               print_debug('No Item Info found', 'PICK_RELEASE');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        inv_quantity_tree_pvt.create_tree
        ( p_api_version_number       => 1.0
        , p_init_msg_lst             => fnd_api.g_false
        , x_return_status            => l_api_return_status
        , x_msg_count                => x_msg_count
        , x_msg_data                 => x_msg_data
        , p_organization_id          => l_organization_id
        , p_inventory_item_id        => l_mo_line.inventory_item_id
        , p_tree_mode                => inv_quantity_tree_pvt.g_transaction_mode
        , p_is_revision_control      => (l_revision_control_code = 2)
        , p_is_lot_control           => (l_lot_control_code = 2)
        , p_is_serial_control        => FALSE
        , p_asset_sub_only           => FALSE
        , p_include_suggestion       => FALSE
        , p_demand_source_type_id    => -99
        , p_demand_source_header_id  => -99
        , p_demand_source_line_id    => -99
        , p_demand_source_delivery   => NULL
        , p_demand_source_name       => NULL
        , p_lot_expiration_date      => SYSDATE
        , x_tree_id                  => l_tree_id
        , p_exclusive                => inv_quantity_tree_pvt.g_exclusive
        , p_pick_release             => inv_quantity_tree_pvt.g_pick_release_yes
        );

        IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_quantity_tree_tbl(l_mo_line.inventory_item_id)  := l_tree_id;
      END IF; -- not exist in quantity tree tbl

      EXIT WHEN l_line_index = p_mo_line_tbl.LAST;
      l_line_index := p_mo_line_tbl.NEXT(l_line_index);
    END LOOP;

    IF (l_debug = 1) THEN
       print_debug('Validations complete, starting pick release', 'PICK_RELEASE');
    END IF;
    l_line_index       := p_mo_line_tbl.FIRST;

    LOOP
      l_mo_line     := p_mo_line_tbl(l_line_index);
      IF (l_debug = 1) THEN
         print_debug('Loop index: ' || TO_CHAR(l_line_index), 'PICK_RELEASE');
         print_debug('MO line   : ' || TO_CHAR(l_mo_line.line_id), 'PICK_RELEASE');
         print_debug('Item      : ' || TO_CHAR(l_mo_line.inventory_item_id), 'PICK_RELEASE');
         print_debug('Quantity  : ' || TO_CHAR(l_mo_line.quantity), 'PICK_RELEASE');
      END IF;

      IF (l_mo_line.return_status <> fnd_api.g_ret_sts_unexp_error
          AND l_mo_line.return_status <> fnd_api.g_ret_sts_error)
      THEN
        IF  l_mo_line.ship_set_id IS NOT NULL
            AND (l_cur_ship_set_id IS NULL OR l_cur_ship_set_id <> l_mo_line.ship_set_id)
        THEN
          SAVEPOINT shipset;
          l_cur_ship_set_id  := l_mo_line.ship_set_id;
          l_start_index      := l_line_index;
          l_start_process    := l_processed_row_count;
          l_qtree_backup_tbl.DELETE;
          IF (l_debug = 1) THEN
             print_debug('Start Pick Set: '|| TO_CHAR(l_cur_ship_set_id), 'PICK_RELEASE');
          END IF;
        ELSIF  l_cur_ship_set_id IS NOT NULL AND l_mo_line.ship_set_id IS NULL THEN
          IF (l_debug = 1) THEN
             print_debug('End of Shipset: '|| TO_CHAR(l_cur_ship_set_id), 'PICK_RELEASE');
          END IF;
          l_cur_ship_set_id  := NULL;
          l_qtree_backup_tbl.DELETE;
        END IF;

        IF  (l_mo_line.ship_set_id IS NOT NULL)
            AND NOT (l_qtree_backup_tbl.EXISTS(l_mo_line.inventory_item_id)) THEN
          IF (l_debug = 1) THEN
             print_debug('Backing up qty tree: '|| TO_CHAR(l_tree_id), 'PICK_RELEASE');
          END IF;
          l_tree_id := l_quantity_tree_tbl(l_mo_line.inventory_item_id);
          inv_quantity_tree_pvt.backup_tree(x_return_status => l_api_return_status, p_tree_id => l_tree_id);

          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          l_qtree_backup_tbl(l_mo_line.inventory_item_id)  := l_tree_id;
        END IF; -- Pick set NOT NULL

        -- Call the Pick Release Process_Line API on the current Move Order Line
        process_line(
          p_mo_line_rec         => l_mo_line
        , p_allow_partial_pick  => p_allow_partial_pick
        , p_grouping_rule_id    => p_grouping_rule_id
        , p_plan_tasks          => p_plan_tasks
        , p_call_wip_api        => p_call_wip_api   --Added bug 4634522
        , x_return_status       => l_api_return_status
        , x_msg_count           => x_msg_count
        , x_msg_data            => x_msg_data
        , x_detail_rec_count    => l_detail_rec_count
        );
        IF (l_debug = 1) THEN
           print_debug('Process Line Return Status = '|| l_api_return_status ||
                       ' : Detail Rec Count = ' || to_char(l_detail_rec_count), 'PICK_RELEASE');
        END IF;

        IF l_api_return_status <> fnd_api.g_ret_sts_success AND p_allow_partial_pick = fnd_api.g_false THEN
           fnd_message.set_name('INV', 'INV_COULD_NOT_PICK_FULL');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        g_mo_line_stat_tbl(l_mo_line.line_id) := l_api_return_status;

        SELECT quantity, line_status
          INTO l_quantity, l_line_status
          FROM mtl_txn_request_lines
         WHERE line_id = l_mo_line.line_id;

        SELECT NVL(SUM(transaction_quantity), 0), NVL(SUM(primary_quantity), 0)
          INTO l_transaction_quantity, l_primary_quantity
          FROM mtl_material_transactions_temp
         WHERE move_order_line_id = l_mo_line.line_id;

        -- If the total allocated quantity is less than the requested
        -- quantity update the move order line to change the
        -- requested quantity to be equal to the allocated quantity.

        IF (l_transaction_quantity < l_quantity)
           OR (l_transaction_quantity = 0 AND l_quantity = 0) THEN
          -- For shipsets, if any of the lines fail to allocate completely,
          -- rollback all allocations

          IF l_cur_ship_set_id IS NOT NULL THEN
            IF (l_debug = 1) THEN
               print_debug('Rollback for pick set: '|| TO_CHAR(l_cur_ship_set_id), 'PICK_RELEASE');
            END IF;
            ROLLBACK TO shipset;
            l_set_index             := l_start_index;
            l_set_process           := l_start_process;

            -- loop through all move order lines for this ship set
            LOOP
              l_mo_line      := p_mo_line_tbl(l_set_index);
              IF (l_debug = 1) THEN
                 print_debug(TO_CHAR(l_set_process) || ' Rolling back allocations for MO line: '
                             ||TO_CHAR(l_mo_line.line_id), 'PICK_RELEASE');
              END IF;

              g_mo_line_stat_tbl(l_mo_line.line_id) := g_not_allocated;

              IF l_qtree_backup_tbl.EXISTS(l_mo_line.inventory_item_id) THEN
                l_tree_id  := l_qtree_backup_tbl(l_mo_line.inventory_item_id);
                IF (l_debug = 1) THEN
                   print_debug('Restoring Quantity Tree: '|| TO_CHAR(l_tree_id), 'PICK_RELEASE');
                END IF;

                inv_quantity_tree_pvt.restore_tree
                ( x_return_status => l_api_return_status
                , p_tree_id       => l_tree_id
                );

                IF (l_api_return_status = fnd_api.g_ret_sts_error) THEN
                  IF (l_debug = 1) THEN
                     print_debug('Error in Restore_Tree', 'Pick_Release');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                     print_debug('Unexpected error in Restore_tree', 'PICK_RELEASE');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                -- delete entry, so we don't restore tree more than once
                l_qtree_backup_tbl.DELETE(l_mo_line.inventory_item_id);
              END IF;

              -- close the move order line
              UPDATE mtl_txn_request_lines
                 SET quantity = 0, quantity_detailed = 0, line_status = 5 ,status_date =sysdate         --BUG 6932648
               WHERE line_id = l_mo_line.line_id;

              -- Exit if there are no more move order lines to detail
              -- or when the next move order is not for the same ship set.
              -- l_set_index should always be equal to the last line
              -- in the current ship set, so that the logic at the
              -- end of the outer loop works correctly.
              EXIT WHEN p_mo_line_tbl.LAST = l_set_index;
              l_set_index    := p_mo_line_tbl.NEXT(l_set_index);

              IF NVL(p_mo_line_tbl(l_set_index).ship_set_id, -1) <> l_cur_ship_set_id THEN
                l_set_index  := p_mo_line_tbl.PRIOR(l_set_index);
                EXIT;
              END IF;

              l_set_process  := l_set_process + 1;
            END LOOP;

            -- At the end of this loop, l_mo_line and l_set_index
            -- point to the last line for this ship set.
            l_line_index            := l_set_index;
            l_cur_ship_set_id       := NULL;
            l_processed_row_count   := l_set_process;
            l_detail_rec_count      := 0;

            --
            -- Bug 2501138:
            -- Set txn qty to 0, so that we don't invoke
            -- wip_picking_pub.allocate_material
            --
            l_transaction_quantity  := 0;
            l_primary_quantity      := 0;
            l_qtree_backup_tbl.DELETE;
            IF (l_debug = 1) THEN
               print_debug('Finished rolling back all lines in shipset', 'PICK_RELEASE');
            END IF;
          ELSE
            UPDATE mtl_txn_request_lines
               SET quantity = l_transaction_quantity
             WHERE line_id = l_mo_line.line_id;

            IF (l_transaction_quantity = 0) THEN
              UPDATE mtl_txn_request_lines
                 SET line_status = 5 ,status_date =sysdate                         --BUG 6932648
               WHERE line_id = l_mo_line.line_id;
            END IF;
          END IF; -- cur ship set id
        END IF; -- transaction quantity < quantity or transaction quantity is 0


        l_processed_row_count  := l_processed_row_count + 1;
        IF (l_debug = 1) THEN
           print_debug('Processed row : ' || TO_CHAR(l_processed_row_count), 'PICK_RELEASE');
           print_debug('MO line ID    : ' || TO_CHAR(l_mo_line.line_id), 'PICK_RELEASE');
           print_debug('Return Status : ' || l_api_return_status, 'PICK_RELEASE');
           print_debug('Dtl rec count : ' || TO_CHAR(l_detail_rec_count), 'PICK_RELEASE');
        END IF;

        l_detail_rec_count     := 0;

        -- Update WIP with allocated qty if alloc qty > 0
        IF p_call_wip_api AND l_transaction_quantity > 0 THEN
          IF (l_debug = 1) THEN
             print_debug('Updating WIP with Allocated Qty: '|| l_primary_quantity, 'PICK_RELEASE');
          END IF;
          wip_picking_pub.allocate_material(
            p_wip_entity_id           => l_mo_line.txn_source_id
          , p_operation_seq_num       => l_mo_line.txn_source_line_id
          , p_inventory_item_id       => l_mo_line.inventory_item_id
          , p_repetitive_schedule_id  => l_mo_line.reference_id
          , p_primary_quantity        => l_primary_quantity
          , x_quantity_allocated      => l_wip_alloc_qty
          , x_return_status           => l_api_return_status
          , x_msg_data                => x_msg_data
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
            IF (l_debug = 1) THEN
               print_debug('Error in wip_picking_pub.allocate_material', 'PICK_RELEASE');
               print_debug('WIP entity ID: ' || TO_CHAR(l_mo_line.txn_source_id), 'PICK_RELEASE');
               print_debug('Op seq num   : ' || TO_CHAR(l_mo_line.txn_source_line_id), 'PICK_RELEASE');
               print_debug('Rep sch ID   : ' || TO_CHAR(l_mo_line.reference_id), 'PICK_RELEASE');
               print_debug('Item ID      : ' || TO_CHAR(l_mo_line.inventory_item_id), 'PICK_RELEASE');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF; -- mo line return status <> ERROR

      EXIT WHEN l_line_index = p_mo_line_tbl.LAST;
      l_line_index  := p_mo_line_tbl.NEXT(l_line_index);
    END LOOP; -- end looping through MO lines

    IF (l_debug = 1) THEN
       print_debug('Done looping through MO lines', 'PICK_RELEASE');
    END IF;

    -- Bug 4349602: Deleting Move Order Lines which are not allocated
    BEGIN
       IF (l_debug = 1) THEN
          print_debug('Deleting closed MOLs..','PICK_RELEASE');
       END IF;
       FORALL ii IN l_mol_id_tbl.FIRST..l_mol_id_tbl.LAST
          DELETE FROM mtl_txn_request_lines  mtrl
           WHERE line_status = 5
             AND line_id = l_mol_id_tbl(ii);
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
           print_debug('Error in Deleting Move Order Lines: ' || sqlerrm
                      ,'PICK_RELEASE');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF l_is_wms_org THEN
      -- Call cartonization API to assign task types and split and merge tasks.
      -- Bug 2666620: Cartonization is not disabled and Packaging Mode is set
      IF (l_debug = 1) THEN
         print_debug('Calling Cartonization Engine', 'PICK_RELEASE');
      END IF;

      -- Bug 2844622: Disable cartonization if WIP patch level is below 11.5.9
      IF g_wip_patch_level >= 1159 THEN
         l_disable_cartonization := 'N';
      ELSE
         l_disable_cartonization := 'Y';
      END IF;

      wms_cartnzn_wrap.cartonize
      ( p_api_version            => l_api_version_number
      , p_init_msg_list          => fnd_api.g_false
      , p_commit                 => fnd_api.g_false
      , p_validation_level       => fnd_api.g_valid_level_full
      , x_return_status          => l_api_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , p_out_bound              => 'Y'
      , p_org_id                 => l_organization_id
      , p_move_order_header_id   => l_mo_header_id
      , p_disable_cartonization  => l_disable_cartonization
      , p_packaging_mode         => wms_cartnzn_wrap.mfg_pr_pkg_mode
      );

      IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
        IF (l_debug = 1) THEN
           print_debug('Cartonization returned with an error status: '||l_api_return_status, 'Pick_Release');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- Standard call to commit
    IF p_commit = fnd_api.g_true THEN
      COMMIT;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('x_return_status = '|| x_return_status, 'PICK_RELEASE');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO pick_release;
      inv_quantity_tree_pvt.clear_quantity_cache;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      ROLLBACK TO pick_release;
      inv_quantity_tree_pvt.clear_quantity_cache;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
  END pick_release;



  --
  -- Name
  --   PROCEDURE Process_Line
  --
  -- Package
  --   INV_Pick_Release_PVT
  --
  -- Purpose
  --   Pick releases the move order line passed in.  Any necessary validation is
  --   assumed to have been done by the caller.
  --
  -- Input Parameters
  --   p_mo_line_rec
  --       The Move Order Line record to pick release
  --   p_allow_partial_pick
  --       TRUE if the pick release process should continue after a line fails to
  --       be detailed completely.
  --       FALSE if the process should stop and roll back all changes if a line
  --       cannot be fully detailed.
  --
  -- Output Parameters
  --   x_return_status
  --       if the process succeeds, the value is
  --   FND_API.G_RET_STS_SUCCESS;
  --       if there is an expected error, the value is
  --             fnd_api.g_ret_sts_error;
  --       if there is an unexpected error, the value is
  --             fnd_api.g_ret_sts_unexp_error;
  --   x_msg_count
  --       if there is one or more errors, the number of error messages
  --        in the buffer
  --   x_msg_data
  --       if there is one and only one error, the error message
  --
  -- (See FND_API package for more details about the above output parameters)
  --

  PROCEDURE process_line
  ( p_mo_line_rec        IN OUT NOCOPY inv_move_order_pub.trolin_rec_type
  , p_allow_partial_pick IN     VARCHAR2 DEFAULT fnd_api.g_true
  , p_grouping_rule_id   IN     NUMBER
  , p_plan_tasks         IN     BOOLEAN
  , p_call_wip_api       IN     BOOLEAN     --Added bug 4634522
  , x_return_status      OUT    NOCOPY  VARCHAR2
  , x_msg_count          OUT    NOCOPY  NUMBER
  , x_msg_data           OUT    NOCOPY  VARCHAR2
  , x_detail_rec_count   OUT    NOCOPY  NUMBER
  ) IS
    -- Empty record for calling Create_Suggestions
    l_demand_rsvs_ordered    inv_reservation_global.mtl_reservation_tbl_type;
    l_request_number         NUMBER; -- MO Header number
    l_primary_uom            VARCHAR2(3); -- The primary UOM for the item
    l_quantity_detailed      NUMBER; -- The quantity for the current MO which was detailed in Primary UOM
    l_num_detail_recs        NUMBER; -- The number of MO Line details for this MO Line.
    l_mol_allocation_status  VARCHAR2(1); -- A flag indicating the status of the MOL Allocation.
    l_quantity_detailed_conv NUMBER; -- The quantity detailed for the current MO in UOM of MO
    l_api_return_status      VARCHAR2(1); -- The return status of APIs called within the Process Line API.
    l_count                  NUMBER;
    l_message                VARCHAR2(255);
    l_allocate_quantity      NUMBER;
    l_use_pick_set_flag      VARCHAR2(1);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       print_debug('Inside Process_Line', 'PROCESS_LINE');
       print_debug('WIP Entity ID: '|| TO_CHAR(p_mo_line_rec.txn_source_id), 'PROCESS_LINE');
       print_debug('Op seq num   : '|| TO_CHAR(p_mo_line_rec.txn_source_line_id), 'PROCESS_LINE');
       print_debug('Rep sch ID   : '|| TO_CHAR(p_mo_line_rec.reference_id), 'PROCESS_LINE');
       print_debug('Item ID      : '|| TO_CHAR(p_mo_line_rec.inventory_item_id), 'PROCESS_LINE');
       print_debug('MO line ID   : '|| TO_CHAR(p_mo_line_rec.line_id), 'PROCESS_LINE');
       print_debug('Unit num     : '|| p_mo_line_rec.unit_number, 'PROCESS_LINE');
       print_debug('Project ID   : '|| TO_CHAR(p_mo_line_rec.project_id), 'PROCESS_LINE');
       print_debug('Task ID      : '|| TO_CHAR(p_mo_line_rec.task_id), 'PROCESS_LINE');
    END IF;
    SAVEPOINT process_line_pvt;
    x_detail_rec_count  := 0;
    l_num_detail_recs   := 0;
    -- Initialize API return status to success
    x_return_status     := fnd_api.g_ret_sts_success;

    -- Bug 4880578: return if MO line has 0 qty
    IF NVL(p_mo_line_rec.quantity,0) = 0 THEN
       IF (l_debug = 1) THEN
          print_debug('MO line has 0 qty: '||p_mo_line_rec.quantity,'PROCESS_LINE');
       END IF;
       x_return_status := g_not_allocated;
       RETURN;
    END IF;

    l_allocate_quantity := nvl(p_mo_line_rec.quantity,0)
                           - nvl(p_mo_line_rec.quantity_detailed, 0);

    IF (l_debug = 1) THEN
       print_debug('Quantity to detail: '||l_allocate_quantity,'PROCESS_LINE');
    END IF;

    -- Return success immediately if the line is already fully detailed
    IF l_allocate_quantity <= 0 THEN
       IF (l_debug = 1) THEN
          print_debug('MO line is already fully detailed', 'PROCESS_LINE');
       END IF;
       RETURN;
    END IF;

    IF p_mo_line_rec.ship_set_id IS NOT NULL THEN
      l_use_pick_set_flag := 'Y';
    ELSE
      l_use_pick_set_flag := 'N';
    END IF;

    -- Bug 2844622: Skip this callback if WIP patch level is below 11.5.9
    IF g_wip_patch_level >= 1159 AND p_call_wip_api THEN -- bug 4634522.Added p_call_wip_api
       --calling WIP callback API
       IF (l_debug = 1) THEN
          print_debug('Calling pre_allocate_material', 'PROCESS_LINE');
       END IF;

       wip_picking_pub.pre_allocate_material
       ( p_wip_entity_id          => p_mo_line_rec.txn_source_id
       , p_operation_seq_num      => p_mo_line_rec.txn_source_line_id
       , p_inventory_item_id      => p_mo_line_rec.inventory_item_id
       , p_repetitive_schedule_id => p_mo_line_rec.reference_id
       , p_use_pickset_flag       => l_use_pick_set_flag
       , p_allocate_quantity      => l_allocate_quantity
       , x_return_status          => l_api_return_status
       , x_msg_data               => x_msg_data
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
         IF (l_debug = 1) THEN
            print_debug('Error in pre_allocate_material','PROCESS_LINE');
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    ELSE
       IF (l_debug = 1) THEN
          print_debug('WIP Patch Level = ' || g_wip_patch_level || ', so skipping pre_allocate_material', 'PROCESS_LINE');
       END IF;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('Calling Create Suggestions for MOLine: '|| p_mo_line_rec.line_id, 'PROCESS_LINE');
    END IF;
    inv_ppengine_pvt.create_suggestions
    ( p_api_version          => 1.0
    , p_init_msg_list        => fnd_api.g_false
    , p_commit               => fnd_api.g_false
    , x_return_status        => l_api_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    , p_transaction_temp_id  => p_mo_line_rec.line_id
    , p_reservations         => l_demand_rsvs_ordered
    , p_suggest_serial       => 'T'
    , p_plan_tasks           => p_plan_tasks
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) THEN
         print_debug('Ret stat: '|| l_api_return_status || ', INV detailing failed', 'PROCESS_LINE');
      END IF;
      fnd_msg_pub.count_and_get(p_count => l_count, p_data => l_message, p_encoded => 'F');

      IF (l_count = 0) THEN
        IF (l_debug = 1) THEN
           print_debug('No message from detailing engine', 'PROCESS_LINE');
        END IF;
      ELSIF (l_count = 1) THEN
        IF (l_debug = 1) THEN
           print_debug(l_message, 'PROCESS_LINE');
        END IF;
      ELSE
        FOR i IN 1 .. l_count LOOP
          l_message  := fnd_msg_pub.get(i, 'F');
          IF (l_debug = 1) THEN
             print_debug(l_message, 'PROCESS_LINE');
          END IF;
        END LOOP;

        fnd_msg_pub.delete_msg();
      END IF;

      BEGIN
        SELECT request_number
          INTO l_request_number
          FROM mtl_txn_request_lines_v
         WHERE line_id = p_mo_line_rec.line_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      fnd_message.set_name('INV', 'INV_DETAILING_FAILED');
      fnd_message.set_token('LINE_NUM', TO_CHAR(p_mo_line_rec.line_number));
      fnd_message.set_token('MO_NUMBER', l_request_number);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('After calling Create Suggestions: Ret Status = '|| l_api_return_status, 'PROCESS_LINE');
    END IF;

    -- Update the detailed quantity (and if possible, the sourcing information)
    SELECT NVL(SUM(primary_quantity), 0), COUNT(*)
      INTO l_quantity_detailed, l_num_detail_recs
      FROM mtl_material_transactions_temp
     WHERE move_order_line_id = p_mo_line_rec.line_id;

    IF (l_debug = 1) THEN
      print_debug('Qty detailed = '|| l_quantity_detailed || ' : Num of Details = ' || l_num_detail_recs, 'PROCESS_LINE');
    END IF;

    -- If the move order line is not fully detailed, update the return status as appropriate.
    IF l_quantity_detailed < p_mo_line_rec.primary_quantity AND p_allow_partial_pick = fnd_api.g_false THEN
      fnd_message.set_name('INV', 'INV_COULD_NOT_PICK_FULL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_num_detail_recs = 0) THEN
      p_mo_line_rec.quantity_detailed  := NVL(l_quantity_detailed, 0) + NVL(p_mo_line_rec.quantity_delivered, 0);
      IF (l_debug = 1) THEN
         print_debug('Updating Move Order Line', 'PROCESS_LINE');
      END IF;
      inv_trolin_util.update_row(p_mo_line_rec);
      l_mol_allocation_status := g_not_allocated;
    ELSIF l_num_detail_recs > 0 THEN
      IF l_quantity_detailed < p_mo_line_rec.primary_quantity THEN
         l_mol_allocation_status := g_partially_allocated;
      ELSE
         l_mol_allocation_status := g_completely_allocated;
      END IF;
      -- Calculate the quantity detailed in the UOM of the move order line
      SELECT primary_uom_code INTO l_primary_uom
        FROM mtl_system_items
       WHERE organization_id = p_mo_line_rec.organization_id
         AND inventory_item_id = p_mo_line_rec.inventory_item_id;

      IF (l_primary_uom <> p_mo_line_rec.uom_code) THEN
        l_quantity_detailed_conv  := inv_convert.inv_um_convert
                                     ( item_id        => p_mo_line_rec.inventory_item_id
                                     , PRECISION      => NULL
                                     , from_quantity  => l_quantity_detailed
                                     , from_unit      => l_primary_uom
                                     , to_unit        => p_mo_line_rec.uom_code
                                     , from_name      => NULL
                                     , to_name        => NULL
                                     );
        IF (l_debug = 1) THEN
           print_debug('After calling convert', 'PROCESS_LINE');
        END IF;

        -- Update the Move Order Line with the quantity which was detailed.
        IF (l_quantity_detailed_conv = -99999) THEN
          fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
          fnd_message.set_token('UOM', p_mo_line_rec.uom_code);
          fnd_message.set_token('ROUTINE', 'Pick Release process');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_quantity_detailed_conv  := l_quantity_detailed;
      END IF;

     /*Bug7834526.We do not need the following call in Rel12 and up.
      -- bug 4634522 .begin
      IF (l_mol_allocation_status = g_partially_allocated) THEN
	IF (l_debug = 1) THEN
         print_debug('  p_mo_line_rec.quantit '||p_mo_line_rec.quantity || ' l_quantity_detailed_conv'||l_quantity_detailed_conv||
                   'p_mo_line_rec.quantity_delivered '||p_mo_line_rec.quantity_delivered  ||'   p_mo_line_rec.detailed_quantity '||
                    p_mo_line_rec.quantity_detailed , 'PROCESS_LINE');
        END IF;

      wip_picking_pub.unallocate_material(
         p_wip_entity_id          => p_mo_line_rec.txn_source_id
       , p_operation_seq_num      => p_mo_line_rec.txn_source_line_id
       , p_inventory_item_id      => p_mo_line_rec.inventory_item_id
       , p_repetitive_schedule_id => p_mo_line_rec.reference_id
       , p_primary_quantity       => p_mo_line_rec.quantity- ( NVL(l_quantity_detailed_conv, 0) + NVL(p_mo_line_rec.quantity_delivered, 0) ) --pass backordered  qty
       , x_return_status          => l_api_return_status
       , x_msg_data               => x_msg_data
       );

       IF (l_debug = 1) THEN
        print_debug('wip_picking_pub.unallocate_material returned '|| l_api_return_status , 'PROCESS_LINE');
       END IF;
      END IF;  --   end if fix for  bug 4634522
    */

      p_mo_line_rec.quantity_detailed  := NVL(l_quantity_detailed_conv, 0) + NVL(p_mo_line_rec.quantity_delivered, 0);
      p_mo_line_rec.pick_slip_date     := SYSDATE;
      IF (l_debug = 1) THEN
        print_debug('Detailed Qty = '|| p_mo_line_rec.quantity_detailed, 'PROCESS_LINE');
        print_debug('Updating Move Order Line', 'PROCESS_LINE');
      END IF;
      inv_trolin_util.update_row(p_mo_line_rec);
      update_mmtt_for_wip(x_return_status, p_mo_line_rec, p_grouping_rule_id);
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        print_debug('Error occurred while updating MMTT with WIP Attributes','PROCESS_LINE');
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- if l_num_detail_rec > 0

    -- If the line was only partially detailed and the API was about to return success,
    -- set the return status to 'P' (Partial) or 'N' (None) instead.
    x_detail_rec_count  := l_num_detail_recs;
    x_return_status := l_mol_allocation_status;
    IF l_debug = 1 THEN
       print_debug('Return status: ' || l_mol_allocation_status,'PROCESS_LINE');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO process_line_pvt;
      IF l_debug = 1 THEN
         print_debug('Error in process line: ' || sqlcode || ', ' || sqlerrm,'PROCESS_LINE');
      END IF;
      x_return_status  := g_not_allocated;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
  END process_line;

  PROCEDURE update_mol_for_wip
  ( x_return_status       OUT  NOCOPY VARCHAR2
  , x_msg_count           OUT  NOCOPY NUMBER
  , x_msg_data            OUT  NOCOPY VARCHAR2
  , p_move_order_line_id  IN   NUMBER
  , p_op_seq_num          IN   NUMBER
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    IF (l_debug = 1) THEN
       print_debug('p_move_order_line_id => '|| p_move_order_line_id, 'update_mol_for_wip');
       print_debug('p_op_seq_num => '|| p_op_seq_num, 'update_mol_for_wip');
    END IF;

    UPDATE mtl_txn_request_lines mol
       SET mol.txn_source_line_id = p_op_seq_num
     WHERE mol.line_id = p_move_order_line_id
       AND EXISTS( SELECT ''
                     FROM mtl_txn_request_headers moh
                    WHERE moh.header_id = mol.header_id
                      AND move_order_type = 5);

    IF SQL%NOTFOUND THEN
      IF (l_debug = 1) THEN
         print_debug('No move order lines being updated', 'update_mol_for_wip');
      END IF;
      x_return_status  := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    UPDATE mtl_material_transactions_temp mmtt
       SET mmtt.trx_source_line_id = p_op_seq_num
     WHERE mmtt.move_order_line_id = p_move_order_line_id
       AND EXISTS( SELECT ''
                     FROM mtl_txn_request_headers moh, mtl_txn_request_lines mol
                    WHERE mol.line_id = mmtt.move_order_line_id
                      AND mol.header_id = moh.header_id
                      AND move_order_type = 5);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END update_mol_for_wip;

  PROCEDURE update_mmtt_for_wip(
    x_return_status   OUT NOCOPY VARCHAR2
  , p_mo_line_rec      IN        inv_move_order_pub.trolin_rec_type
  , p_grouping_rule_id IN        NUMBER
  ) IS
    l_wip_entity_type    NUMBER;
    l_repetitive_line_id NUMBER;
    l_department_id      NUMBER;
    l_department_code    bom_departments.department_code%TYPE;
    l_push_vs_pull       VARCHAR2(4);
    l_pick_slip_number   NUMBER;
    l_index              NUMBER                                 := 0;
    l_msg_data VARCHAR2(2000);
    l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    CURSOR c_mmtt IS
      SELECT transaction_temp_id, revision, subinventory_code, locator_id, transfer_subinventory, transfer_to_location, pick_slip_number
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id = p_mo_line_rec.line_id;
  BEGIN
    get_wip_attributes(
      x_return_status           => x_return_status
    , x_wip_entity_type         => l_wip_entity_type
    , x_push_vs_pull            => l_push_vs_pull
    , x_repetitive_line_id      => l_repetitive_line_id
    , x_department_id           => l_department_id
    , x_department_code         => l_department_code
    , x_pick_slip_number        => l_pick_slip_number
    , p_wip_entity_id           => p_mo_line_rec.txn_source_id
    , p_operation_seq_num       => p_mo_line_rec.txn_source_line_id
    , p_rep_schedule_id         => p_mo_line_rec.reference_id
    , p_organization_id         => p_mo_line_rec.organization_id
    , p_inventory_item_id       => p_mo_line_rec.inventory_item_id
    , p_transaction_type_id     => p_mo_line_rec.transaction_type_id
    , p_get_pick_slip_number    => FALSE
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      print_debug('Error Occurred while getting WIP Attributes','UPDATE_MMTT_FOR_WIP');
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    FOR c_mmtt_rec IN c_mmtt LOOP
      l_index  := l_index + 1;

      IF c_mmtt_rec.pick_slip_number IS NULL THEN
        IF g_wip_patch_level >= 1159 THEN
          inv_pr_pick_slip_number.get_pick_slip_number(
            p_pick_grouping_rule_id  => p_grouping_rule_id
          , p_org_id                 => p_mo_line_rec.organization_id
          , p_wip_entity_id          => p_mo_line_rec.txn_source_id
          , p_rep_schedule_id        => p_mo_line_rec.reference_id
          , p_operation_seq_num      => p_mo_line_rec.txn_source_line_id
          , p_dept_id                => l_department_id
          , p_push_or_pull           => l_push_vs_pull
          , p_supply_subinventory    => c_mmtt_rec.transfer_subinventory
          , p_supply_locator_id      => c_mmtt_rec.transfer_to_location
          , p_project_id             => p_mo_line_rec.project_id
          , p_task_id                => p_mo_line_rec.task_id
          , p_src_subinventory       => c_mmtt_rec.subinventory_code
          , p_src_locator_id         => c_mmtt_rec.locator_id
          , p_inventory_item_id      => p_mo_line_rec.inventory_item_id
          , p_revision               => c_mmtt_rec.revision
          , p_lot_number             => NULL
          , x_pick_slip_number       => l_pick_slip_number
          , x_api_status             => x_return_status
          , x_error_message          => l_msg_data
          );

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
             IF (l_debug = 1) THEN
                print_debug('Error occurred in getting the Pick Slip Number: '|| l_msg_data, 'UPDATE_WITH_PICK_SLIP');
             END IF;
             fnd_message.set_name('INV','INV_NO_PICK_SLIP_NUMBER');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          BEGIN
            SELECT WSH_PICK_SLIP_NUMBERS_S.NEXTVAL INTO l_pick_slip_number FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
               fnd_message.set_name('INV','INV_NO_PICK_SLIP_NUMBER');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
          END;
        END IF;
      ELSE
        l_pick_slip_number := c_mmtt_rec.pick_slip_number;
      END IF;

      IF p_mo_line_rec.transaction_type_id = INV_GLOBALS.G_TYPE_XFER_ORDER_WIP_ISSUE THEN
        UPDATE mtl_material_transactions_temp
           SET transaction_source_id      = p_mo_line_rec.txn_source_id
             , trx_source_line_id         = p_mo_line_rec.txn_source_line_id
             , demand_source_header_id    = p_mo_line_rec.txn_source_id
             , demand_source_line         = p_mo_line_rec.txn_source_line_id
             , transaction_source_type_id = inv_globals.g_sourcetype_wip
             , transaction_type_id        = p_mo_line_rec.transaction_type_id
             , transaction_action_id      = inv_globals.g_action_issue
             , wip_entity_type            = l_wip_entity_type
             , repetitive_line_id         = l_repetitive_line_id
             , operation_seq_num          = p_mo_line_rec.txn_source_line_id
             , department_id              = l_department_id
             , department_code            = l_department_code
             , lock_flag                  = 'N'
             , primary_switch             = l_index
             , wip_supply_type            = 1
             , negative_req_flag          = SIGN(transaction_quantity)
             , required_flag              = '1'
             , pick_slip_number           = l_pick_slip_number
         WHERE transaction_temp_id        = c_mmtt_rec.transaction_temp_id;
      ELSIF p_mo_line_rec.transaction_type_id = INV_GLOBALS.G_TYPE_XFER_ORDER_REPL_SUBXFR THEN
        UPDATE mtl_material_transactions_temp
           SET transaction_source_id      = p_mo_line_rec.txn_source_id
             , trx_source_line_id         = p_mo_line_rec.txn_source_line_id
             , demand_source_header_id    = p_mo_line_rec.txn_source_id
             , demand_source_line         = p_mo_line_rec.txn_source_line_id
             , transaction_source_type_id = inv_globals.g_sourcetype_inventory
             , transaction_type_id        = p_mo_line_rec.transaction_type_id
             , transaction_action_id      = inv_globals.g_action_subxfr
             , wip_entity_type            = l_wip_entity_type
             , wip_supply_type            = NULL -- Bug#2057540
             , pick_slip_number           = l_pick_slip_number
         WHERE transaction_temp_id        = c_mmtt_rec.transaction_temp_id;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('Exception Occurred: Code = ' || SQLCODE || ' : Error '|| SQLERRM, 'UPDATE_MMTT_FOR_WIP');
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END update_mmtt_for_wip;

  PROCEDURE get_wip_attributes(
    x_return_status           OUT NOCOPY VARCHAR2
  , x_wip_entity_type         OUT NOCOPY NUMBER
  , x_push_vs_pull            OUT NOCOPY VARCHAR2
  , x_repetitive_line_id      OUT NOCOPY NUMBER
  , x_department_id           OUT NOCOPY NUMBER
  , x_department_code         OUT NOCOPY VARCHAR2
  , x_pick_slip_number        OUT NOCOPY NUMBER
  , p_wip_entity_id            IN        NUMBER
  , p_operation_seq_num        IN        NUMBER
  , p_rep_schedule_id          IN        NUMBER
  , p_organization_id          IN        NUMBER
  , p_inventory_item_id        IN        NUMBER
  , p_transaction_type_id      IN        NUMBER
  , p_get_pick_slip_number     IN        BOOLEAN
  ) IS

    CURSOR c_wip_entity_type IS
      SELECT entity_type
        FROM wip_entities
       WHERE wip_entity_id = p_wip_entity_id;

    CURSOR c_repetitive_line_id IS
      SELECT line_id
        FROM wip_repetitive_schedules
       WHERE repetitive_schedule_id = p_rep_schedule_id
         AND organization_id = p_organization_id
         AND wip_entity_id = p_wip_entity_id;

    CURSOR c_push_vs_pull IS
      SELECT decode(wip_supply_type,1,'PUSH',2,'PULL',3,'PULL')
        FROM wip_requirement_operations
       WHERE p_rep_schedule_id IS null
         AND wip_entity_id = p_wip_entity_id
         AND inventory_item_id = p_inventory_item_id
         AND operation_seq_num = p_operation_seq_num
         AND organization_id   = p_organization_id
      UNION ALL
      SELECT decode(wip_supply_type,1,'PUSH',2,'PULL',3,'PULL')
        FROM wip_requirement_operations
       WHERE p_rep_schedule_id IS NOT NULL
         AND wip_entity_id = p_wip_entity_id
         AND inventory_item_id = p_inventory_item_id
         AND operation_seq_num = p_operation_seq_num
         AND organization_id   = p_organization_id
         AND repetitive_schedule_id = p_rep_schedule_id;

    CURSOR c_discrete_dept IS
      SELECT wo.department_id, bd.department_code
        FROM wip_operations wo, bom_departments bd
       WHERE wo.wip_entity_id = p_wip_entity_id
         AND wo.organization_id = p_organization_id
         AND wo.operation_seq_num = p_operation_seq_num
         AND bd.department_id = wo.department_id;

    CURSOR c_repetitive_dept IS
      SELECT wo.department_id, bd.department_code
        FROM wip_operations wo, bom_departments bd
       WHERE wo.wip_entity_id = p_wip_entity_id
         AND wo.organization_id = p_organization_id
         AND wo.operation_seq_num = p_operation_seq_num
         AND wo.repetitive_schedule_id = p_rep_schedule_id
         AND bd.department_id = wo.department_id;

    CURSOR c_flow_dept IS
      SELECT bos.department_id, bd.department_code
        FROM bom_departments bd
           , bom_operation_sequences bos
           , bom_operational_routings bor
           , wip_flow_schedules wfs
       WHERE wfs.wip_entity_id = p_wip_entity_id
         AND wfs.organization_id = p_organization_id
         AND bor.assembly_item_id = wfs.primary_item_id
         AND bor.organization_id = wfs.organization_id
         AND (bor.alternate_routing_designator = wfs.alternate_routing_designator
              OR (wfs.alternate_routing_designator IS NULL
                  AND bor.alternate_routing_designator IS NULL))
         AND bos.routing_sequence_id = bor.routing_sequence_id
         AND bos.operation_type = 1
         AND bos.effectivity_date >= SYSDATE
         AND bd.department_id = bos.department_id;

    l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    -- Entity type
    OPEN c_wip_entity_type;
    FETCH c_wip_entity_type INTO x_wip_entity_type;
    IF c_wip_entity_type%NOTFOUND THEN
      IF (l_debug = 1) THEN
         print_debug('Couldnt determine Entity Type for EntityID = '|| p_wip_entity_id, 'UPDATE_MMTT_FOR_WIP');
      END IF;
      CLOSE c_wip_entity_type;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE c_wip_entity_type;

    -- Departments
    IF x_wip_entity_type IN (1,5,6) THEN
      OPEN c_discrete_dept;
      FETCH c_discrete_dept INTO x_department_id, x_department_code;
      CLOSE c_discrete_dept;
    ELSIF x_wip_entity_type = 2 THEN
      OPEN c_repetitive_dept;
      FETCH c_repetitive_dept INTO x_department_id, x_department_code;
      CLOSE c_repetitive_dept;
    ELSIF x_wip_entity_type = 4 THEN
      OPEN c_flow_dept;
      FETCH c_flow_dept INTO x_department_id, x_department_code;
      CLOSE c_flow_dept;
    END IF;

    -- Repetitive Line ID
    IF p_transaction_type_id = INV_GLOBALS.G_TYPE_XFER_ORDER_WIP_ISSUE THEN
      IF x_wip_entity_type = 2 THEN
        IF p_rep_schedule_id IS NULL THEN
          IF (l_debug = 1) THEN
             print_debug('Repetitive Schedule ID cannot be null for Entity Type 2', 'UPDATE_MMTT_FOR_WIP');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSE
          OPEN c_repetitive_line_id;
          FETCH c_repetitive_line_id INTO x_repetitive_line_id;
          IF c_repetitive_line_id%NOTFOUND THEN
            IF (l_debug = 1) THEN
               print_debug('Unable to determine RepLineID for RepSchID '||p_rep_schedule_id, 'UPDATE_MMTT_FOR_WIP');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          CLOSE c_repetitive_line_id;
        END IF;
      END IF;
    END IF;

    -- Supply Type
    IF x_wip_entity_type IN (1, 2, 5, 6) THEN
      OPEN c_push_vs_pull;
      FETCH c_push_vs_pull INTO x_push_vs_pull;
      CLOSE c_push_vs_pull;
    ELSIF x_wip_entity_type = 4 THEN
      x_push_vs_pull := 'PULL';
    END IF;

    -- Pick Slip Number
    IF p_get_pick_slip_number THEN
      SELECT WSH_PICK_SLIP_NUMBERS_S.NEXTVAL INTO x_pick_slip_number FROM DUAL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_wip_attributes;

  FUNCTION get_mo_alloc_stat RETURN VARCHAR2 IS
    l_mo_alloc_stat  VARCHAR2(1) := g_not_allocated;
    l_debug          NUMBER      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_first_line_id  NUMBER      := 0;
    l_last_line_id   NUMBER      := 0;
    l_cur_line_id    NUMBER      := 0;

    l_num_success    NUMBER      := 0;
    l_num_partial    NUMBER      := 0;
    l_num_no_alloc   NUMBER      := 0;
  BEGIN
    l_first_line_id := g_mo_line_stat_tbl.FIRST;
    l_last_line_id  := g_mo_line_stat_tbl.LAST;

    IF l_debug = 1 THEN
       print_debug('First line ID: '  || to_char(l_first_line_id) || ', Last line ID: ' || to_char(l_last_line_id), 'GET_MO_ALLOC_STAT');
    END IF;

    l_cur_line_id := l_first_line_id;
    LOOP
      IF l_debug = 1 THEN
         print_debug('Line ID: ' || to_char(l_cur_line_id) || ', Line alloc stat: ' || g_mo_line_stat_tbl(l_cur_line_id), 'GET_MO_ALLOC_STAT');
      END IF;

      IF g_mo_line_stat_tbl(l_cur_line_id) = g_completely_allocated THEN
         l_num_success := l_num_success + 1;
      ELSIF g_mo_line_stat_tbl(l_cur_line_id) = g_partially_allocated THEN
         l_num_partial := l_num_partial + 1;
      ELSIF g_mo_line_stat_tbl(l_cur_line_id) = g_not_allocated THEN
         l_num_no_alloc := l_num_no_alloc + 1;
      END IF;

      IF l_cur_line_id = l_last_line_id THEN
         EXIT;
      END IF;

      l_cur_line_id := g_mo_line_stat_tbl.NEXT(l_cur_line_id);
    END LOOP;

    -- Bug 5469486: Add the number of lines where MOL creation failed
    l_num_no_alloc := l_num_no_alloc + NVL(g_mol_fail_count,0);

    IF l_debug = 1 THEN
       print_debug('Line status counts:: Successes: ' || l_num_success ||', Partial: ' || l_num_partial  ||', None: '    || l_num_no_alloc, 'GET_MO_ALLOC_STAT');
    END IF;

    IF l_num_success > 0 AND l_num_partial = 0 AND l_num_no_alloc = 0 THEN
       l_mo_alloc_stat := g_completely_allocated;
    ELSIF l_num_partial > 0 OR (l_num_success > 0 AND l_num_no_alloc > 0) THEN
       l_mo_alloc_stat := g_partially_allocated;
    ELSE
       l_mo_alloc_stat := g_not_allocated;
    END IF;

    IF l_debug = 1 THEN
       print_debug('Overall status: ' || l_mo_alloc_stat, 'GET_MO_ALLOC_STAT');
    END IF;

    RETURN l_mo_alloc_stat;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 1 THEN
         print_debug('Error: ' || SQLCODE || ', ' || SQLERRM , 'GET_MO_ALLOC_STAT');
      END IF;
      RETURN g_not_allocated;
  END get_mo_alloc_stat;

END inv_wip_picking_pvt;

/
