--------------------------------------------------------
--  DDL for Package WMS_TASK_DISPATCH_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_DISPATCH_GEN" AUTHID CURRENT_USER AS
  /* $Header: WMSTASKS.pls 120.4.12010000.3 2011/09/20 12:04:49 abasheer ship $ */

  --  variables representing missing records and tables

  --G_MISS_DETAIL_REC        INV_AUTODETAIL.pp_row;
  --G_MISS_DETAIL_REC_TBL    INV_AUTODETAIL.pp_row_table;
  --G_MISS_SERIAL_REC        INV_AUTODETAIL.serial_row;--G_MISS_SERIAL_REC_TBL    INV_AUTODETAIL.serial_row_table;



  --  procedure


  --Stuff for Calling the Task Dispatching Engine


  TYPE task_rec_cur_tp IS REF CURSOR;

  TYPE t_genref IS REF CURSOR;

  TYPE task_rec_tp IS RECORD(
    task_id         NUMBER
  , task_zone       VARCHAR2(10)
  , task_locator    NUMBER
  , task_revision   VARCHAR2(3)
  , task_uom        VARCHAR2(10)
  , task_quantity   NUMBER
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  , task_lot_number VARCHAR2(80)
  , task_type       NUMBER
  , task_priority   NUMBER
  );

  TYPE lpn_lot_qty_rec IS RECORD(
    lpn_id     NUMBER
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  , lot_number VARCHAR2(80)
  , qty        NUMBER
  );

  TYPE lpn_lot_qty_tb IS TABLE OF lpn_lot_qty_rec INDEX BY BINARY_INTEGER;

  --  PL/SQL TABLE used to store lot_number and qty for passed in lpn_id

  t_lpn_lot_qty_table lpn_lot_qty_tb;

  FUNCTION get_lpn_lot_qty(p_lot_number IN VARCHAR2)
    RETURN NUMBER;

  -- r12.1 Advanced Replenishment Project 6681109
  TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE pick_release_rec IS RECORD(
				  batch_id     NUMBER
				  , delivery_detail_id      NUMBER
				  );

  TYPE pick_release_tab IS TABLE OF pick_release_rec INDEX BY BINARY_INTEGER;
  -- r12.1 Advanced Replenishment Project 6681109


  PROCEDURE next_task(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2 := NULL
  , p_sign_on_equipment_id  IN            NUMBER := NULL
  , p_sign_on_equipment_srl IN            VARCHAR2 := NULL
  , p_task_type             IN            VARCHAR2 := 'PICKING'
  , x_nbr_tasks             OUT NOCOPY    NUMBER
  , p_lpn_id                IN            NUMBER := fnd_api.g_miss_num
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_task_type             OUT NOCOPY    NUMBER
  , p_sign_on_device_id     IN            NUMBER := NULL
  , x_avail_device_id       OUT NOCOPY    NUMBER
  );

  -- This procedure will dispatch the Cluster Pick Tasks
  PROCEDURE next_cluster_pick_task(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2 := NULL
  , p_sign_on_equipment_id  IN            NUMBER := NULL
  , p_sign_on_equipment_srl IN            VARCHAR2 := NULL
  , p_task_type             IN            VARCHAR2 := 'PICKING'
  , x_nbr_tasks             OUT NOCOPY    NUMBER
  , p_lpn_id                IN            NUMBER DEFAULT NULL
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_task_type             OUT NOCOPY    NUMBER
  , p_sign_on_device_id     IN            NUMBER := NULL
  , x_avail_device_id       OUT NOCOPY    NUMBER
  , p_max_clusters          IN            NUMBER := 0
  , x_deliveries_list       OUT NOCOPY    VARCHAR2
  , x_cartons_list          OUT NOCOPY    VARCHAR2
  );

  PROCEDURE complete_pick(
    p_lpn               IN            VARCHAR2
  , p_container_item_id IN            NUMBER := NULL
  , p_org_id            IN            NUMBER
  , p_temp_id           IN            NUMBER
  , p_loc               IN            NUMBER
  , p_sub               IN            VARCHAR2
  , p_from_lpn_id       IN            NUMBER
  , p_txn_hdr_id        IN            NUMBER
  , p_user_id           IN            NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  , p_ok_to_process     OUT NOCOPY    VARCHAR2
  );

  -- This lpn will be used during the picking process. If the user specifies
  -- a from lpn, this procedure will figure out if the lpn in question will
  -- satisfy the pick in question
  -- It will return 1 if this is the case, 0 if not and 2 if the item does
  -- not exist in the lpn, 3 if the qty is not adequate and 4 if it already
  -- has been loaded

  PROCEDURE lpn_match(
    p_lpn                 IN            NUMBER
  , p_org_id              IN            NUMBER
  , p_item_id             IN            NUMBER
  , p_rev                 IN            VARCHAR2
  , p_lot                 IN            VARCHAR2
  , p_qty                 IN            NUMBER
  , p_uom                 IN            VARCHAR2
  , x_match               OUT NOCOPY    NUMBER
  , x_sub                 OUT NOCOPY    VARCHAR2
  , x_loc                 OUT NOCOPY    VARCHAR2
  , x_qty                 OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_temp_id             IN            NUMBER
  , p_wms_installed       IN            VARCHAR2
  , p_transaction_type_id IN            NUMBER
  , p_cost_group_id       IN            NUMBER
  , p_is_sn_alloc         IN            VARCHAR2
  , p_action              IN            NUMBER
  , x_temp_id             OUT NOCOPY    NUMBER
  , x_loc_id              OUT NOCOPY    NUMBER
  , x_lpn_lot_vector      OUT NOCOPY    VARCHAR2
  , x_lpn_qty             OUT NOCOPY    NUMBER  --Added bug 3946813
  );

  -- This API will process lots and serials. It will insert into the
  -- mtl_transaction_lots_temp and mtl_serial_numbers_temp table
  -- The input parameter p_action determines whether it is lot controlled (1)
  -- , serial controlled (2) or lot and serial controlled (3)

  PROCEDURE process_lot_serial(
    p_org_id        IN            NUMBER
  , p_user_id       IN            NUMBER
  , p_temp_id       IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_qty           IN            NUMBER
  , p_uom           IN            VARCHAR2
  , p_lot           IN            VARCHAR2 := NULL
  , p_fm_serial     IN            VARCHAR2
  , p_to_serial     IN            VARCHAR2
  , p_action        IN            NUMBER := 1
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  FUNCTION get_primary_quantity(p_item_id IN NUMBER, p_organization_id IN NUMBER, p_from_quantity IN NUMBER, p_from_unit IN VARCHAR2)
    RETURN NUMBER;

  FUNCTION can_pickdrop(txn_temp_id IN NUMBER)
    RETURN VARCHAR2;

  PROCEDURE load_pick(
    p_to_lpn              IN            VARCHAR2
  , p_container_item_id   IN            NUMBER := NULL
  , p_org_id              IN            NUMBER
  , p_temp_id             IN            NUMBER
  , p_from_lpn            IN            VARCHAR2
  , p_from_lpn_id         IN            NUMBER := NULL
  , p_act_sub             IN            VARCHAR2
  , p_act_loc             IN            NUMBER
  , p_entire_lpn          IN            VARCHAR2 := 'N'
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_loc_rsn_id          IN            NUMBER
  , p_qty_rsn_id          IN            NUMBER
  , p_sn_allocated_flag   IN            VARCHAR2
  , p_task_id             IN            NUMBER
  , p_user_id             IN            NUMBER
  , p_qty                 IN            NUMBER
  , p_qty_uom             IN            VARCHAR2
  , p_is_revision_control IN            VARCHAR2
  , p_is_lot_control      IN            VARCHAR2
  , p_is_serial_control   IN            VARCHAR2
  , p_item_id             IN            NUMBER
  , p_act_rev             IN            VARCHAR2
  , p_lot                 IN            VARCHAR2
  , p_ok_to_process       OUT NOCOPY    VARCHAR2
  , p_pick_qty_remaining  IN            NUMBER
  , x_temp_id             OUT NOCOPY    NUMBER
  , p_lots_to_delete      IN            VARCHAR2
  , p_mmtt_to_update      IN            VARCHAR2
  , p_serial_number       IN            VARCHAR2
  , x_out_lpn             OUT NOCOPY    NUMBER
  );

  PROCEDURE validate_pick_to_lpn(
    p_api_version_number IN            NUMBER
  , p_init_msg_lst       IN            VARCHAR2 := fnd_api.g_false
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_organization_id    IN            NUMBER
  , p_pick_to_lpn        IN            VARCHAR2
  , p_temp_id            IN            NUMBER
  , p_project_id         IN            NUMBER := NULL
  , p_task_id            IN            NUMBER := NULL
  );

  PROCEDURE multiple_lpn_pick(
    p_lpn_id            IN            NUMBER
  , p_lpn_qty           IN            NUMBER
  , p_org_id            IN            NUMBER
  , p_temp_id           IN            NUMBER
  , x_temp_id           OUT NOCOPY    NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  , p_sn_allocated_flag IN            VARCHAR2
  , p_uom_code          IN            VARCHAR2
  , p_to_lpn_id         IN            NUMBER
  , p_entire_lpn        IN            VARCHAR2
  );

  PROCEDURE multiple_pick(
    p_pick_qty            IN            NUMBER
  , p_org_id              IN            NUMBER
  , p_temp_id             IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_sn_allocated_flag   IN            VARCHAR2
  , p_act_uom             IN            VARCHAR2
  , p_from_lpn            IN            VARCHAR2
  , p_from_lpn_id         IN            NUMBER
  , p_to_lpn              IN            VARCHAR2
  , p_ok_to_process       OUT NOCOPY    VARCHAR2
  , p_is_revision_control IN            VARCHAR2
  , p_is_lot_control      IN            VARCHAR2
  , p_is_serial_control   IN            VARCHAR2
  , p_act_rev             IN            VARCHAR2
  , p_lot                 IN            VARCHAR2
  , p_act_sub             IN            VARCHAR2
  , p_act_loc             IN            NUMBER
  , p_container_item_id   IN            NUMBER := NULL
  , p_entire_lpn          IN            VARCHAR2
  , p_pick_qty_remaining  IN            NUMBER
  , x_temp_id             OUT NOCOPY    NUMBER
  , p_serial_number       IN            VARCHAR2
  );

  PROCEDURE insert_mmtt_pack(
    p_temp_id           IN            NUMBER
  , p_lpn_id            IN            NUMBER
  , p_transfer_lpn      IN            VARCHAR2
  , p_container_item_id IN            NUMBER := NULL
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  );

  PROCEDURE insert_task(
    p_org_id        IN            NUMBER
  , p_user_id       IN            NUMBER
  , p_eqp_ins       IN            VARCHAR2
  , p_temp_id       IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  );

  PROCEDURE mydebug(msg IN VARCHAR2);

  PROCEDURE create_lpn(
    p_organization_id               NUMBER
  , p_lpn             IN            VARCHAR2
  , p_lpn_id          OUT NOCOPY    NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  );

  -- This API will be called to modify the License Plate Number and/or
  -- the container item associated with the LPN

  PROCEDURE change_lpn(
    p_org_id        IN            NUMBER
  , p_container     IN            NUMBER := NULL
  , p_lpn_name      IN            VARCHAR2 := NULL
  , p_sug_lpn_name  IN            VARCHAR2 := NULL
  , x_ret           OUT NOCOPY    NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  /* This API will be called when the pick task is dropped off
  at the staging location. This will take in the temp id, see if there are
    any mmtt lines that have this temp id as the parent id. If yes, then it
    means that this line is a consolidated bulk pick task. Consequently, only
    the child mmtt lines should be transacted
    */
  PROCEDURE pick_drop(
    p_temp_id       IN            NUMBER
  , p_txn_header_id IN            NUMBER
  , p_org_id        IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_from_lpn_id   IN            NUMBER
  , p_drop_lpn      IN            VARCHAR2
  , p_loc_reason_id IN            NUMBER   DEFAULT NULL
  , p_sub           IN            VARCHAR  DEFAULT NULL
  , p_loc           IN            NUMBER   DEFAULT NULL
  , p_orig_sub      IN            VARCHAR  DEFAULT NULL
  , p_orig_loc      IN            VARCHAR  DEFAULT NULL
  , p_user_id       IN            NUMBER   DEFAULT NULL
  , p_task_type     IN            NUMBER   DEFAULT NULL
  , p_commit        IN            VARCHAR2 DEFAULT 'Y'
  );

  /* This API is similar to the next_task API. It has been expanded to
  support Pick By Label. User will scan a LPN label, The next task for that
    LPN will be returned. The user will not be allowed to drop off the LPN if
    further tasks exist for that LPN. If no further picking tasks exist for
    the LPN scanned, then the user will be directed to the pick drop page.
    x_nbr_tasks will  bring back 0 if there are no further undispatched
    picking tasks which means that the user should drop it off,  or -1 if no
    tasks exist at all or the actual number of tasks remaining for the LPN*/
  PROCEDURE pick_by_label(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2 := NULL
  , p_sign_on_equipment_id  IN            NUMBER := NULL
  , p_sign_on_equipment_srl IN            VARCHAR2 := NULL
  , p_task_type             IN            VARCHAR2 := 'PICKING'
  , x_nbr_tasks             OUT NOCOPY    NUMBER
  , p_lpn_id                IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

  PROCEDURE manual_pick(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2 := NULL
  , p_sign_on_equipment_id  IN            NUMBER := NULL
  , p_sign_on_equipment_srl IN            VARCHAR2 := NULL
  , p_task_type             IN            VARCHAR2 := 'PICKING'
  , p_pick_slip_id          IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

  /* This API will return the number of tasks that still need to be performed
  for a given carton. If it returns more than 1, the user should not be
    allowed to drop off the carton*/
  PROCEDURE check_carton(
    p_carton_id     IN            NUMBER
  , p_org_id        IN            NUMBER
  , x_nbr_tasks     OUT NOCOPY    NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  /* This API will return the number of tasks that still need to be performed
  for a given carton. If it returns more than 1, the user should not be
    allowed to drop off the carton*/
  PROCEDURE check_pack_lpn(
    p_lpn           IN            VARCHAR2
  , p_org_id        IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  -- Procedure
  --  check_is_reservable_sub
  -- Description
  --  check from db tables whether the sub specified in
  --  the input is a reservable sub or not.
  PROCEDURE check_is_reservable_sub(
    x_return_status     OUT NOCOPY    VARCHAR2
  , p_organization_id   IN            VARCHAR2
  , p_subinventory_code IN            VARCHAR2
  , x_is_reservable_sub OUT NOCOPY    BOOLEAN
  );

  PROCEDURE create_mo(
    p_org_id                     IN            NUMBER
  , p_inventory_item_id          IN            NUMBER
  , p_qty                        IN            NUMBER
  , p_uom                        IN            VARCHAR2
  , p_lpn                        IN            NUMBER
  , p_project_id                 IN            NUMBER := NULL
  , p_task_id                    IN            NUMBER := NULL
  , p_reference                  IN            VARCHAR2 := NULL
  , p_reference_type_code        IN            NUMBER := NULL
  , p_reference_id               IN            NUMBER := NULL
  , p_lot_number                 IN            VARCHAR2
  , p_revision                   IN            VARCHAR2
  , p_header_id                  IN OUT NOCOPY NUMBER
  , p_sub                        IN            VARCHAR := NULL
  , p_loc                        IN            NUMBER := NULL
  , x_line_id                    OUT NOCOPY    NUMBER
  , p_inspection_status          IN            NUMBER := NULL
  , p_txn_source_id              IN            NUMBER := fnd_api.g_miss_num
  , p_transaction_type_id        IN            NUMBER := fnd_api.g_miss_num
  , p_transaction_source_type_id IN            NUMBER := fnd_api.g_miss_num
  , p_wms_process_flag           IN            NUMBER := NULL
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_from_cost_group_id         IN            NUMBER := NULL
  , p_transfer_org_id            IN            NUMBER DEFAULT NULL
  );

  PROCEDURE cleanup_task(
    p_temp_id       IN            NUMBER
  , p_qty_rsn_id    IN            NUMBER
  , p_user_id       IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  PROCEDURE get_td_lot_lov_count(
    x_lot_num_lov_count   OUT NOCOPY    NUMBER
  , p_organization_id     IN            NUMBER
  , p_item_id             IN            NUMBER
  , p_lot_number          IN            VARCHAR2
  , p_transaction_type_id IN            NUMBER
  , p_wms_installed       IN            VARCHAR2
  , p_lpn_id              IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_txn_temp_id         IN            NUMBER
  );

  PROCEDURE validate_sub_loc_status(
    p_wms_installed    IN            VARCHAR2
  , p_temp_id          IN            NUMBER
  , p_confirmed_sub    IN            VARCHAR2
  , p_confirmed_loc_id IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , x_result           OUT NOCOPY    NUMBER
  );

  PROCEDURE validate_pick_drop_sub(
    p_temp_id            IN            NUMBER
  , p_confirmed_drop_sub IN            VARCHAR2
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  );

  -- Added for bug 12853197
  PROCEDURE validate_pick_drop_sub(
    p_temp_id             IN            NUMBER
  , p_confirmed_drop_sub  IN            VARCHAR2
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , x_lpn_controlled_flag OUT NOCOPY    VARCHAR2
  );

  PROCEDURE create_lock_mmtt_temp_id(lock_name IN VARCHAR2, x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE bulk_pick(
    p_temp_id            IN            NUMBER
  , p_txn_hdr_id         IN            NUMBER
  , p_org_id             IN            NUMBER
  , p_pick_qty_remaining IN            NUMBER
  , p_user_id            IN            NUMBER
  , x_new_txn_hdr_id     OUT NOCOPY    NUMBER
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_reason_id          IN            NUMBER  := 0--Added bug 3765153
  );

procedure validate_loaded_lpn_cg( p_organization_id       IN  NUMBER,
			     p_inventory_item_id     IN  NUMBER,
			     p_subinventory_code     IN  VARCHAR2,
			     p_locator_id            IN  NUMBER,
			     p_revision              IN  VARCHAR2,
			     p_lot_number            IN  VARCHAR2,
			     p_lpn_id                IN  NUMBER,
			     p_transfer_lpn_id       IN  NUMBER,
			     p_lot_control           IN  NUMBER,
     			     p_revision_control      IN  NUMBER,
			     x_commingle_exist       OUT NOCOPY VARCHAR2,
			     x_return_status         OUT NOCOPY VARCHAR2); --Added bug3813165


--BUG 4452825 --Moved here from WMS_CONTAINER2_PUB Starts-----

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE validate_pick_drop_lpn
/*---------------------------------------------------------------------*/
-- Purpose
--   This API validates the drop LPN scanned by the user when depositing
--   a picked LPN to shipping staging.  It performs the following checks:
--
--    > Checks if the drop LPN is a new LPN generated by the user.
--      If it is, then no further checking is required.  (The LPN will
--      be created by the Pick Complete API).
--
--    > Checks if the user specified the picked LPN as the drop LPN,
--      and if so return an error.
--
--    > Checks to make sure the drop LPN contains picked inventory.
--      If the drop LPN is not picked for a sales order, check nested LPNs
--      (if they exist).  For the first nested LPN found which is picked
--      return a status of success.  If none found, return an error status.
--
--    > Make sure delivery IDs if they exist are the same for
--      both the picked LPN as well as the drop LPN.  If either
--      one is not yet associated with delivery ID, allow pick drop
--      to continue by returning a status of success.  For the drop LPN,
--      check nested LPNs if a delivery ID cannot be determined directly.
--
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_pick_lpn_id           The LPN ID picked by the user for this pick task
--
--   p_drop_lpn              The destination LPN into which the picked
--                           LPN (p_pick_lpn_id) will be packed.
--
--
-- Output Parameters
--   x_return_status
--       fnd_api.g_ret_sts_success      if all checks pass.
--       fnd_api.g_ret_sts_error        if any check fails.
--       fnd_api.g_ret_sts_unexp_error  if there is an unexpected error
--   x_msg_count
--       if there is an error (or more than one) error, the number of
--       error messages in the buffer
--   x_msg_data
--       if there is only one error, the error message

FUNCTION validate_pick_drop_lpn
(  p_api_version_number    IN   NUMBER                       ,
   p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
   p_pick_lpn_id           IN   NUMBER                       ,
   p_organization_id       IN   NUMBER                       ,
   p_drop_lpn              IN   VARCHAR2                     ,
   p_drop_sub              IN   VARCHAR2                     ,
   p_drop_loc              IN   NUMBER
   ) RETURN NUMBER;


PROCEDURE default_pick_drop_lpn
  (  p_api_version_number    IN   NUMBER                       ,
     p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
     p_pick_lpn_id           IN   NUMBER                       ,
     p_organization_id       IN   NUMBER                       ,
     x_lpn_number           OUT   nocopy VARCHAR2);

--BUG 4452825 --Moved here from WMS_CONTAINER2_PUB Ends-------

END wms_task_dispatch_gen;

/
