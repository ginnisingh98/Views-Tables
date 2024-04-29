--------------------------------------------------------
--  DDL for Package INV_CYC_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CYC_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVCYCLS.pls 120.2.12010000.2 2010/06/21 09:59:16 abasheer ship $ */

TYPE t_genref IS REF CURSOR;

/* Cycle Count Entry Record subtype */
SUBTYPE cc_entry IS MTL_CYCLE_COUNT_ENTRIES%ROWTYPE;

/* Serial number cycle count entry record subtype */
SUBTYPE cc_serial_entry IS MTL_CC_SERIAL_NUMBERS%ROWTYPE;


--      Name: GET_CYC_LOV
--
--      Input parameters:
--       p_cycle_count        Restricts LOV SQL to the user input text
--       p_organization_id    Organization ID
--
--      Output parameters:
--       x_cyc_lov            Returns LOV rows as a reference cursor
--
--      Functions: This API returns valid cycle counts
--
PROCEDURE get_cyc_lov
  (x_cyc_lov           OUT   NOCOPY t_genref,
   p_cycle_count       IN    VARCHAR2,
   p_organization_id   IN    NUMBER);


PROCEDURE process_entry
  (p_cycle_count_header_id    IN    NUMBER            ,
   p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_revision                 IN    VARCHAR2 := NULL  ,
   p_lot_number               IN    VARCHAR2 := NULL  ,
   p_from_serial_number       IN    VARCHAR2 := NULL  ,
   p_to_serial_number         IN    VARCHAR2 := NULL  ,
   p_count_quantity           IN    NUMBER            ,
   p_count_uom                IN    VARCHAR2          ,
   p_unscheduled_count_entry  IN    NUMBER            ,
   p_user_id                  IN    NUMBER            ,
   p_cost_group_id            IN    NUMBER   := NULL
   ,p_secondary_uom           IN VARCHAR2    := NULL  -- INVCONV, NSRIVAST
   ,p_secondary_qty           IN NUMBER      := NULL  -- INVCONV, NSRIVAST
   );

 /* start of fix for 4539926 */
   /* Added this procedure to delete orphan wms_dispatched_tasks records
      which will exist if the cycle count has been queued and is performed
      through cycle count menu */
   PROCEDURE delete_wdt
     (p_cycle_count_header_id    IN    NUMBER            ,
      p_organization_id          IN    NUMBER            ,
      p_subinventory             IN    VARCHAR2          ,
      p_locator_id               IN    NUMBER            ,
      p_parent_lpn_id            IN    NUMBER            ,
      p_inventory_item_id        IN    NUMBER            ,
      p_revision                 IN    VARCHAR2          ,
      p_lot_number               IN    VARCHAR2          ,
      p_from_serial_number       IN    VARCHAR2          ,
      p_to_serial_number         IN    VARCHAR2          ,
      p_count_quantity           IN    NUMBER            ,
      p_count_uom                IN    VARCHAR2          ,
      p_unscheduled_count_entry  IN    NUMBER            ,
      p_user_id                  IN    NUMBER            ,
      p_cost_group_id            IN    NUMBER            );
   /* end of fix for 4539926 */

PROCEDURE insert_row;

PROCEDURE update_row;

PROCEDURE current_to_prior;

PROCEDURE current_to_first;

PROCEDURE entry_to_current
  (p_count_date               IN       DATE      ,
   p_counted_by_employee_id   IN       NUMBER    ,
   p_system_quantity          IN       NUMBER    ,
   p_reference                IN       VARCHAR2  ,
   p_primary_uom_quantity     IN       NUMBER    ,
   p_sec_system_quantity IN NUMBER DEFAULT NULL -- nsinghi Bug#6052831 Added this parameter.
  );

PROCEDURE zero_count_logic;

PROCEDURE get_tolerances
  (pre_approve_flag                IN   VARCHAR2,
   x_approval_tolerance_positive   OUT  NOCOPY NUMBER,
   x_approval_tolerance_negative   OUT  NOCOPY NUMBER,
   x_cost_tolerance_positive       OUT  NOCOPY NUMBER,
   x_cost_tolerance_negative       OUT  NOCOPY NUMBER);


PROCEDURE recount_logic
  (p_approval_tolerance_positive    IN   NUMBER,
   p_approval_tolerance_negative    IN   NUMBER,
   p_cost_tolerance_positive        IN   NUMBER,
   p_cost_tolerance_negative        IN   NUMBER
   );

PROCEDURE tolerance_logic
  (p_approval_tolerance_positive    IN   NUMBER,
   p_approval_tolerance_negative    IN   NUMBER,
   p_cost_tolerance_positive        IN   NUMBER,
   p_cost_tolerance_negative        IN   NUMBER);

PROCEDURE valids;

PROCEDURE in_tolerance;

PROCEDURE out_tolerance;

PROCEDURE no_adj_req;

PROCEDURE pre_insert;

PROCEDURE pre_update;

PROCEDURE final_preupdate_logic;

PROCEDURE delete_reservation;

PROCEDURE duplicate_entries;

PROCEDURE post_commit;

PROCEDURE system_quantity
  (x_system_quantity   OUT   NOCOPY NUMBER);

-- nsinghi bug#6052831. Created overloaded procedure to handle secondary qty.
PROCEDURE system_quantity (
   x_system_quantity OUT NOCOPY NUMBER
   , x_sec_system_quantity OUT NOCOPY NUMBER
);

PROCEDURE value_variance
  (x_value_variance   OUT   NOCOPY NUMBER);

FUNCTION wms_is_installed
  (p_organization_id  IN  NUMBER) RETURN BOOLEAN;

FUNCTION get_item_cost
  (in_org_id      NUMBER,
   in_item_id     NUMBER,
   in_locator_id  NUMBER)
  RETURN NUMBER;

PROCEDURE is_serial_entered
  (event             IN    VARCHAR2,
   entered           OUT   NOCOPY NUMBER);

PROCEDURE new_serial_number;

PROCEDURE existing_serial_number;

FUNCTION check_serial_number_location (issue_receipt VARCHAR2) RETURN
  BOOLEAN;

FUNCTION is_serial_loaded ( p_organization_id   IN  NUMBER,
                            p_inventory_item_id IN  NUMBER,
                            p_serial_number     IN  VARCHAR2,
                            p_lpn_id            IN  NUMBER
                          )
  RETURN number;

PROCEDURE perform_serial_adj_txn;

PROCEDURE count_entry_status_code;

PROCEDURE update_serial_row;

PROCEDURE mark;

PROCEDURE unmark (cycle_cnt_entry_id NUMBER);

PROCEDURE get_profiles;

PROCEDURE get_employee
  (p_organization_id   IN   NUMBER);

PROCEDURE process_summary
  (p_cycle_count_header_id    IN    NUMBER            ,
   p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER    := NULL ,
   p_parent_lpn_id            IN    NUMBER    := NULL ,
   p_unscheduled_count_entry  IN    NUMBER            ,
   p_user_id                  IN    NUMBER);

PROCEDURE inv_serial_info
(p_from_serial_number       IN       VARCHAR2,
 p_to_serial_number         IN       VARCHAR2,
 x_prefix                   OUT      NOCOPY VARCHAR2,
 x_quantity                 OUT      NOCOPY VARCHAR2,
 x_from_number              OUT      NOCOPY VARCHAR2,
 x_to_number                OUT      NOCOPY VARCHAR2,
 x_errorcode                OUT      NOCOPY NUMBER);

PROCEDURE get_default_cost_group_id
  (p_organization_id        IN       NUMBER,
   p_subinventory           IN       VARCHAR2,
   x_out                    OUT      NOCOPY NUMBER);

PROCEDURE get_cost_group_id
  (p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_revision                 IN    VARCHAR2 := NULL  ,
   p_lot_number               IN    VARCHAR2 := NULL  ,
   p_serial_number            IN    VARCHAR2 := NULL  ,
   x_out                      OUT   NOCOPY NUMBER);

PROCEDURE ok_proc;

PROCEDURE serial_tolerance_logic
  (p_serial_adj_qty   IN   NUMBER,
   p_app_tol_pos      IN   NUMBER,
   p_app_tol_neg      IN   NUMBER,
   p_cost_tol_pos     IN   NUMBER,
   p_cost_tol_neg     IN   NUMBER);

PROCEDURE get_final_count_info;

-- This gets the number of scheduled cycle count
-- entries left for the given cycle count header ID
PROCEDURE get_scheduled_entry
  (p_cycle_count_header_id   IN    NUMBER,
   x_count                   OUT   NOCOPY NUMBER);

-- This is called for inserting dynamic lots which
-- was entered/typed in instead of dynamically generating it
PROCEDURE insert_dynamic_lot
  (p_api_version               IN      NUMBER,
   p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id         IN      NUMBER,
   p_organization_id           IN      NUMBER,
   p_lot_number                IN      VARCHAR2,
   p_expiration_date           IN OUT  NOCOPY DATE,
   p_transaction_temp_id       IN      NUMBER DEFAULT NULL,
   p_transaction_action_id     IN      NUMBER DEFAULT NULL,
   p_transfer_organization_id  IN      NUMBER DEFAULT NULL,
   p_status_id                 IN      NUMBER,
   p_update_status             IN      VARCHAR2 := 'FALSE',
   x_object_id                 OUT     NOCOPY NUMBER,
   x_return_status             OUT     NOCOPY VARCHAR2,
   x_msg_count                 OUT     NOCOPY NUMBER,
   x_msg_data                  OUT     NOCOPY VARCHAR2);


-- This is called for updating the serial number status for
-- predefined serials
PROCEDURE update_serial_status
  (p_api_version            IN   NUMBER,
   p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
   p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id      IN   NUMBER,
   p_organization_id        IN   NUMBER,
   p_from_serial_number     IN   VARCHAR2,
   p_to_serial_number       IN   VARCHAR2,
   p_current_status         IN   NUMBER,
   p_serial_status_id       IN   NUMBER,
   p_update_serial_status   IN   VARCHAR2,
   p_lot_number             IN   VARCHAR2,
   x_return_status          OUT  NOCOPY VARCHAR2,
   x_msg_count              OUT  NOCOPY NUMBER,
   x_msg_data               OUT  NOCOPY VARCHAR2);

-- This is a wrapper to call inventory insert_range_serial
PROCEDURE insert_range_serial
  (p_api_version            IN   NUMBER,
   p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
   p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id      IN   NUMBER,
   p_organization_id        IN   NUMBER,
   p_from_serial_number     IN   VARCHAR2,
   p_to_serial_number       IN   VARCHAR2,
   p_revision               IN   VARCHAR2,
   p_lot_number             IN   VARCHAR2,
   p_current_status         IN   NUMBER,
   p_serial_status_id       IN   NUMBER,
   p_update_serial_status   IN   VARCHAR2,
   x_return_status          OUT  NOCOPY VARCHAR2,
   x_msg_count              OUT  NOCOPY NUMBER,
   x_msg_data               OUT  NOCOPY VARCHAR2);

-- This gets the system quantity for the item given
-- the available input information
PROCEDURE get_system_quantity
  (p_organization_id      IN    NUMBER            ,
   p_subinventory         IN    VARCHAR2          ,
   p_locator_id           IN    NUMBER            ,
   p_parent_lpn_id        IN    NUMBER            ,
   p_inventory_item_id    IN    NUMBER            ,
   p_revision             IN    VARCHAR2 := NULL  ,
   p_lot_number           IN    VARCHAR2 := NULL  ,
   p_uom_code             IN    VARCHAR2          ,
   x_system_quantity      OUT   NOCOPY NUMBER);

-- This will clean up any outstanding cycle count tasks
-- that were completed as a result of performing a summary
-- count.  The result can be such that the user is performing
-- task A but when doing a summary count on an LPN, could have
-- finished a different task B for which he/she was dispatched
-- to perform it but he/she was not explicitly doing it.
-- Without this call, we can have the case where the user still has
-- a task that has been dispatched to him/her which is no longer
-- active since it has already been completed.
PROCEDURE clean_up_tasks
  (p_transaction_temp_id  IN    NUMBER);

--BUG# 9734316
PROCEDURE update_cc_status
	(x_result_out						OUT		NOCOPY VARCHAR2,
   x_cc_id								OUT		NOCOPY VARCHAR2,
   p_organization_id			IN		NUMBER,
   p_parent_lpn_id				IN		NUMBER,
   p_inventory_item_id		IN		NUMBER,
   p_sub_code							IN		VARCHAR2,
   p_loc_id								IN		NUMBER,
   p_cc_header_id					IN		NUMBER,
   p_task_id							IN		NUMBER,
   p_revision							IN		VARCHAR2);
 --BUG# 9734316


END INV_CYC_LOVS;

/
