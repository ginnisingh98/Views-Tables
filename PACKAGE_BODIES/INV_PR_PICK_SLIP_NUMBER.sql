--------------------------------------------------------
--  DDL for Package Body INV_PR_PICK_SLIP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PR_PICK_SLIP_NUMBER" AS
  /* $Header: INVPRPNB.pls 120.5 2006/10/31 19:45:07 stdavid ship $ */


  --
  -- PACKAGE TYPES
  --
  TYPE grprectyp IS RECORD(
    grouping_rule_id              NUMBER
  , use_order_ps                  VARCHAR2(1)  := 'N'
  , use_customer_ps               VARCHAR2(1)  := 'N'
  , use_ship_to_ps                VARCHAR2(1)  := 'N'
  , use_carrier_ps                VARCHAR2(1)  := 'N'
  , use_ship_priority_ps          VARCHAR2(1)  := 'N'
  , use_trip_stop_ps              VARCHAR2(1)  := 'N'
  , use_delivery_ps               VARCHAR2(1)  := 'N'
  , use_src_sub_ps                VARCHAR2(1)  := 'N'
  , use_src_locator_ps            VARCHAR2(1)  := 'N'
  , use_item_ps                   VARCHAR2(1)  := 'N'
  , use_revision_ps               VARCHAR2(1)  := 'N'
  , use_lot_ps                    VARCHAR2(1)  := 'N'
  , use_jobsch_ps                 VARCHAR2(1)  := 'N'
  , use_oper_seq_ps               VARCHAR2(1)  := 'N'
  , use_dept_ps                   VARCHAR2(1)  := 'N'
  , use_supply_type_ps            VARCHAR2(1)  := 'N'
  , use_supply_sub_ps             VARCHAR2(1)  := 'N'
  , use_supply_loc_ps             VARCHAR2(1)  := 'N'
  , use_project_ps                VARCHAR2(1)  := 'N'
  , use_task_ps                   VARCHAR2(1)  := 'N'
  , pick_method                   VARCHAR2(30)  := '-99');

  TYPE grptabtyp IS TABLE OF grprectyp
    INDEX BY BINARY_INTEGER;

  TYPE wipkeyrectyp IS RECORD
  ( grouping_rule_id     NUMBER
  , organization_id      NUMBER
  , wip_entity_id        NUMBER
  , rep_schedule_id      NUMBER
  , operation_seq_num    NUMBER
  , dept_id              NUMBER
  , push_or_pull         VARCHAR2(4)
  , supply_subinventory  VARCHAR2(10)
  , supply_locator_id    NUMBER
  , project_id           NUMBER
  , task_id              NUMBER
  , src_subinventory     VARCHAR2(10)
  , src_locator_id       NUMBER
  , inventory_item_id    NUMBER
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  , lot_number           VARCHAR2(80)
  , revision             VARCHAR2(3)
  , pick_slip_number     NUMBER
  );

  TYPE wipkeytabtyp IS TABLE OF wipkeyrectyp
    INDEX BY BINARY_INTEGER;

  --
  -- PACKAGE VARIABLES
  --
  g_wip_pskey_table   wipkeytabtyp;
  g_rule_table        grptabtyp;
  g_hash_base         NUMBER        := 1;
  g_hash_size         NUMBER        := POWER(2, 25);
  g_pkg_name CONSTANT VARCHAR2(50)  := 'INV_PR_PICK_SLIP_NUMBER';
  g_trace_on          NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),2);
  -- For cahing the limit information for an org
  g_prev_org_id       NUMBER;
  g_pickslip_limit    NUMBER;

  /***********************************************************************************************
  *                                                                                              *
  *                             Shipping Related Procedures                                      *
  *                                                                                              *
  ***********************************************************************************************/

  --
  -- Name
  --   PROCEDURE INSERT_KEY
  --
  -- Purpose
  --   Insert new key to table and returns newly generated Pick Slip Number
  --   This procedure is used by Shipping GET_PICK_SLIP_NUMBER Procedure.
  --

  PROCEDURE insert_key
  ( l_hash_value        IN   NUMBER
  , l_insert_key_rec    IN   keyrectyp
  , x_pick_slip_number  OUT  NOCOPY  NUMBER
  , x_error_message     OUT  NOCOPY  VARCHAR2
  ) IS
  BEGIN
    SELECT wsh_pick_slip_numbers_s.NEXTVAL
      INTO x_pick_slip_number
      FROM DUAL;

    g_pskey_table(l_hash_value)                   := l_insert_key_rec;
    g_pskey_table(l_hash_value).counter           := 1;
    g_pskey_table(l_hash_value).pick_slip_number  := x_pick_slip_number;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_NUMBER.INSERT_KEY';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.INSERT_KEY',3);
      END IF;
  END insert_key;

  --
  -- Name
  --   PROCEDURE CREATE_HASH
  --
  -- Purpose
  --   Generate a hash value for the given values for the column strings.
  --   This procedure is used by Shipping GET_PICK_SLIP_NUMBER Procedure.
  --
  -- Input Parameter
  --   p_rule_index         => Index to the Grouping Rule Table
  --   p_header_id          => Order Header ID
  --   p_customer_id        => Customer ID
  --   p_ship_method_code   => Ship Method
  --   p_ship_to_loc_id     => Ship to Location
  --   p_shipment_priority  => Shipment Priority
  --   p_subinventory       => SubInventory
  --   p_trip_stop_id       => Trip Stop
  --   p_delivery_id        => Delivery
  --   p_inventory_item_id  => Item
  --   p_locator_id         => Locator
  --   p_lot_number         => Lot Number
  --   p_revision           => Revision
  --   p_org_id             => Organization
/* FP-J PAR Replenishment Count:
      Introduced four new DEFAULT NULL inputs dest_subinventory, dest_locator_id,
      project_id, task_id to the signature of the procedure. */
  --   p_dest_subinventory     => Destination Subinventory
  --   p_dest_locator_id       => Destination Locator Id
  --   p_project_id            => Project Id
  --   p_task_id               => Task Id

  --
  -- Output Parameter
  --   x_hash_value         => Hash Value for g_pskey_table
  --   x_Insert_key_Rec     => keyRecTyp
  --   x_error_message      => Error message
  --

  PROCEDURE create_hash(
    p_rule_index        IN     NUMBER
  , p_header_id         IN     NUMBER
  , p_customer_id       IN     NUMBER
  , p_ship_method_code  IN     VARCHAR2
  , p_ship_to_loc_id    IN     NUMBER
  , p_shipment_priority IN     VARCHAR2
  , p_subinventory      IN     VARCHAR2
  , p_trip_stop_id      IN     NUMBER
  , p_delivery_id       IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_locator_id        IN     NUMBER
  , p_lot_number        IN     VARCHAR2
  , p_revision          IN     VARCHAR2
  , p_org_id            IN     NUMBER
  , x_hash_value        OUT    NOCOPY NUMBER
  , x_insert_key_rec    OUT    NOCOPY keyrectyp
  , x_error_message     OUT    NOCOPY VARCHAR2
  , p_dest_subinventory IN     VARCHAR2 DEFAULT NULL
  , p_dest_locator_id   IN     NUMBER   DEFAULT NULL
  , p_project_id        IN     NUMBER   DEFAULT NULL
  , p_task_id           IN     NUMBER   DEFAULT NULL
) IS
    l_hash_string VARCHAR2(2000) := NULL;
  BEGIN
    l_hash_string                      := TO_CHAR(g_rule_table(p_rule_index).grouping_rule_id);
    x_insert_key_rec.grouping_rule_id  := g_rule_table(p_rule_index).grouping_rule_id;

    IF (g_rule_table(p_rule_index).use_order_ps = 'Y') THEN
      l_hash_string               := l_hash_string || '-' || TO_CHAR(p_header_id);
      x_insert_key_rec.header_id  := p_header_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_customer_ps = 'Y') THEN
      l_hash_string                 := l_hash_string || '-' || TO_CHAR(p_customer_id);
      x_insert_key_rec.customer_id  := p_customer_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_carrier_ps = 'Y') THEN
      l_hash_string                      := l_hash_string || '-' || p_ship_method_code;
      x_insert_key_rec.ship_method_code  := p_ship_method_code;
    END IF;

    IF (g_rule_table(p_rule_index).use_ship_to_ps = 'Y') THEN
      l_hash_string                    := l_hash_string || '-' || TO_CHAR(p_ship_to_loc_id);
      x_insert_key_rec.ship_to_loc_id  := p_ship_to_loc_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_ship_priority_ps = 'Y') THEN
      l_hash_string                       := l_hash_string || '-' || p_shipment_priority;
      x_insert_key_rec.shipment_priority  := p_shipment_priority;
    END IF;

    IF (g_rule_table(p_rule_index).use_trip_stop_ps = 'Y') THEN
      l_hash_string                  := l_hash_string || '-' || TO_CHAR(p_trip_stop_id);
      x_insert_key_rec.trip_stop_id  := p_trip_stop_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_delivery_ps = 'Y') THEN
      l_hash_string                 := l_hash_string || '-' || TO_CHAR(p_delivery_id);
      x_insert_key_rec.delivery_id  := p_delivery_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_src_sub_ps = 'Y') THEN
      l_hash_string                  := l_hash_string || '-' || p_subinventory;
      x_insert_key_rec.subinventory  := p_subinventory;
    END IF;

    IF (g_rule_table(p_rule_index).use_src_locator_ps = 'Y') THEN
      l_hash_string                := l_hash_string || '-' || TO_CHAR(p_locator_id);
      x_insert_key_rec.locator_id  := p_locator_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_item_ps = 'Y') THEN
      l_hash_string                       := l_hash_string || '-' || TO_CHAR(p_inventory_item_id);
      x_insert_key_rec.inventory_item_id  := p_inventory_item_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_lot_ps = 'Y') THEN
      l_hash_string                := l_hash_string || '-' || p_lot_number;
      x_insert_key_rec.lot_number  := p_lot_number;
    END IF;

    IF (g_rule_table(p_rule_index).use_revision_ps = 'Y') THEN
      l_hash_string              := l_hash_string || '-' || p_revision;
      x_insert_key_rec.revision  := p_revision;
    END IF;

/* PAR Replenishment Count: It is now possible to define grouping rule
   with Destination Sub, Destination Locator, Project and Task for Pick Wave also */
    IF (g_rule_table(p_rule_index).use_supply_sub_ps = 'Y') THEN
      l_hash_string                      := l_hash_string || '-' || p_dest_subinventory;
      x_insert_key_rec.dest_subinventory := p_dest_subinventory;
    END IF;

    IF (g_rule_table(p_rule_index).use_supply_loc_ps = 'Y') THEN
      l_hash_string                      := l_hash_string || '-' || TO_CHAR(p_dest_locator_id);
      x_insert_key_rec.dest_locator_id   := p_dest_locator_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_project_ps = 'Y') THEN
      l_hash_string                := l_hash_string || '-' || TO_CHAR(p_project_id);
      x_insert_key_rec.project_id  := p_project_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_task_ps = 'Y') THEN
      l_hash_string             := l_hash_string || '-' || TO_CHAR(p_task_id);
      x_insert_key_rec.task_id  := p_task_id;
    END IF;


    x_insert_key_rec.organization_id   := p_org_id;
    l_hash_string                      := l_hash_string || '-' || TO_CHAR(p_org_id);
    x_hash_value                       := DBMS_UTILITY.get_hash_value(NAME => l_hash_string, base => g_hash_base, hash_size => g_hash_size);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_NUMBER.CREATE_HASH';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.CREATE_HASH',3);
      END IF;
  END create_hash;

  --
  -- Name
  --   PROCEDURE GET_PICK_SLIP_NUMBER (Used by Shipping)
  --
  -- Purpose
  --   Returns Pick Slip Number and whether a Pick Slip should be printed. This
  --   overloaded procedure is used by Shipping.
  --
  -- Input Parameters
  --   p_ps_mode               => Pick Slip Print Mode: I = Immediate, E = Deferred
  --   p_pick_grouping_rule_id => Pick Grouping Rule ID
  --   p_org_id                => Organization ID
  --   p_header_id             => Order Header ID
  --   p_customer_id           => Customer ID
  --   p_ship_method_code      => Ship Method
  --   p_ship_to_loc_id        => Ship to Location
  --   p_shipment_priority     => Shipment Priority
  --   p_subinventory          => SubInventory
  --   p_trip_stop_id          => Trip Stop
  --   p_delivery_id           => Delivery
  --   p_inventory_item_id     => Inventory Item ID
  --   p_locator_id            => Locator ID
  --   p_lot_number            => Lot Number
  --   p_revision              => Revision
/* FP-J PAR Replenishment Count:
      Introduced four new DEFAULT NULL inputs dest_subinventory, dest_locator_id,
      project_id, task_id to the signature of the procedure. */
  --   p_dest_subinventory     => Destination Subinventory
  --   p_dest_locator_id       => Destination Locator Id
  --   p_project_id            => Project Id
  --   p_task_id               => Task Id

  --
  -- Output Parameters
  --   x_pick_slip_number      => Pick Slip Number
  --   x_ready_to_print        => FND_API.G_TRUE or FND_API.G_FALSE
  --   x_api_status            => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_error_message         => Error message

  PROCEDURE get_pick_slip_number(
    p_ps_mode               IN     VARCHAR2
  , p_pick_grouping_rule_id IN     NUMBER
  , p_org_id                IN     NUMBER
  , p_header_id             IN     NUMBER
  , p_customer_id           IN     NUMBER
  , p_ship_method_code      IN     VARCHAR2
  , p_ship_to_loc_id        IN     NUMBER
  , p_shipment_priority     IN     VARCHAR2
  , p_subinventory          IN     VARCHAR2
  , p_trip_stop_id          IN     NUMBER
  , p_delivery_id           IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_locator_id            IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_revision              IN     VARCHAR2
  , x_pick_slip_number      OUT    NOCOPY NUMBER
  , x_ready_to_print        OUT    NOCOPY VARCHAR2
  , x_call_mode             OUT    NOCOPY VARCHAR2
  , x_api_status            OUT    NOCOPY VARCHAR2
  , x_error_message         OUT    NOCOPY VARCHAR2
  , p_dest_subinventory     IN     VARCHAR2
  , p_dest_locator_id       IN     NUMBER
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  ) IS
    -- cursor to get the pick slip grouping rule
/* FP-J PAR Replenishment Count:
     Introduced 4 new columns fetch in the below cursor viz.,
      dest_sub_flag, dest_loc_flag, project_flag, task_flag */
    CURSOR ps_rule(v_pgr_id IN NUMBER) IS
      SELECT NVL(order_number_flag, 'N')
           , NVL(customer_flag, 'N')
           , NVL(ship_to_flag, 'N')
           , NVL(carrier_flag, 'N')
           , NVL(shipment_priority_flag, 'N')
           , NVL(trip_stop_flag, 'N')
           , NVL(delivery_flag, 'N')
           , NVL(subinventory_flag, 'N')
           , NVL(locator_flag, 'N')
           , NVL(dest_sub_flag, 'N')
           , NVL(dest_loc_flag, 'N')
           , NVL(project_flag, 'N')
           , NVL(task_flag, 'N')
           , NVL(item_flag, 'N')
           , NVL(revision_flag, 'N')
           , NVL(lot_flag, 'N')
           , NVL(pick_method, '-99')
        FROM wsh_pick_grouping_rules
       WHERE pick_grouping_rule_id = v_pgr_id;

    -- cursor to get number of times called before printer
    CURSOR get_limit(v_org_id IN NUMBER) IS
      SELECT NVL(pick_slip_lines, -1)
        FROM wsh_shipping_parameters
       WHERE organization_id = v_org_id;

    l_limit          NUMBER;
    l_insert_key_rec keyrectyp;
    l_hash_value     NUMBER;
    l_rule_index     NUMBER;
    l_found          BOOLEAN;
  BEGIN
    IF (wsh_pick_list.g_batch_id IS NOT NULL) THEN
      -- Needed for inventory to know whether this API is triggered Manually or thru Pick Release
      x_call_mode  := 'Y';
    END IF;

    /* Get the number of times called for a pick slip before
       setting the ready to print flag to TRUE. If print is immediate,
       pickslip limit is cached and fetched only if current org defers from the last org */

    IF p_ps_mode = 'I' THEN
      IF p_org_id = g_prev_org_id THEN
        l_limit  := g_pickslip_limit;
      ELSE
        OPEN get_limit(p_org_id);
        FETCH get_limit INTO l_limit;

        IF get_limit%NOTFOUND THEN
          x_error_message  := 'Organization ' || TO_CHAR(p_org_id) || ' does not exist. ';
          x_api_status     := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;

        g_prev_org_id     := p_org_id;
        g_pickslip_limit  := l_limit;
      END IF;
    END IF;

    -- Set ready to print flag to FALSE initially
    x_ready_to_print  := fnd_api.g_false;

    -- Bug 2777688: Do not store the pick slip numbers generated when the l_limt value is 1
    -- as we want to generate a new one for each line
    -- Bug 5212435: Store the pick slip number even when limit is 1
    IF (p_ps_mode = 'I' AND l_limit = 1) THEN
      SELECT wsh_pick_slip_numbers_s.NEXTVAL
      INTO x_pick_slip_number
      FROM dual;
      wsh_pr_pick_slip_number.g_print_ps_table(wsh_pr_pick_slip_number.g_print_ps_table.COUNT + 1) :=
        x_pick_slip_number;
      x_ready_to_print :=  FND_API.G_TRUE;
      x_api_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    -- l_found is used to determine whether Grouping Rule exists in Rule Table.
    l_found           := FALSE;

    IF g_rule_table.EXISTS(p_pick_grouping_rule_id) THEN
      l_found       := TRUE;
      l_rule_index  := p_pick_grouping_rule_id;
    END IF;

    IF ((l_found) AND (g_rule_table(l_rule_index).pick_method = g_cluster_pick_method)) THEN
      /* Cluster Picking:
           Do not store the pick slip numbers generated, as a new one is required for each line. */
      SELECT wsh_pick_slip_numbers_s.NEXTVAL
        INTO x_pick_slip_number
        FROM DUAL;

      x_api_status  := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    -- Rule is not found. Fetch the attributes concerning the Pick Slip Grouping Rule
    IF (NOT l_found) THEN
      l_rule_index := p_pick_grouping_rule_id;
      OPEN ps_rule(p_pick_grouping_rule_id);
/* FP-J PAR Replenishment Count: Introduced fetching 4 new columns
   from cursor ps_rule into g_rule_table viz., use_supply_sub_ps,
   use_supply_loc_ps, use_project_ps, use_task_ps. Note that supply_sub and supply_loc
   denote Destination Subinv and Destination Locator in usage */
      FETCH ps_rule INTO g_rule_table(l_rule_index).use_order_ps
                       , g_rule_table(l_rule_index).use_customer_ps
                       , g_rule_table(l_rule_index).use_ship_to_ps
                       , g_rule_table(l_rule_index).use_carrier_ps
                       , g_rule_table(l_rule_index).use_ship_priority_ps
                       , g_rule_table(l_rule_index).use_trip_stop_ps
                       , g_rule_table(l_rule_index).use_delivery_ps
                       , g_rule_table(l_rule_index).use_src_sub_ps
                       , g_rule_table(l_rule_index).use_src_locator_ps
                       , g_rule_table(l_rule_index).use_supply_sub_ps
                       , g_rule_table(l_rule_index).use_supply_loc_ps
                       , g_rule_table(l_rule_index).use_project_ps
                       , g_rule_table(l_rule_index).use_task_ps
                       , g_rule_table(l_rule_index).use_item_ps
                       , g_rule_table(l_rule_index).use_revision_ps
                       , g_rule_table(l_rule_index).use_lot_ps
                       , g_rule_table(l_rule_index).pick_method;

      IF ps_rule%NOTFOUND THEN
        x_error_message  := 'Pick grouping rule ' || TO_CHAR(p_pick_grouping_rule_id) || ' does not exist';
        x_api_status     := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;

      g_rule_table(l_rule_index).grouping_rule_id  := p_pick_grouping_rule_id;

      -- Rule Table is cached with the Rule and the Attributes. Now PickSlip Number has to be Generated.

      IF (g_rule_table(l_rule_index).pick_method = g_cluster_pick_method) THEN
        /* Cluster Picking:
             Do not store the pick slip numbers generated, as a new one is required for each line. */
        SELECT wsh_pick_slip_numbers_s.NEXTVAL
          INTO x_pick_slip_number
          FROM DUAL;
      ELSE
        -- Generate a new PickSlip Number and Insert it for future use.
        create_hash(
          p_rule_index                 => l_rule_index
        , p_header_id                  => p_header_id
        , p_customer_id                => p_customer_id
        , p_ship_method_code           => p_ship_method_code
        , p_ship_to_loc_id             => p_ship_to_loc_id
        , p_shipment_priority          => p_shipment_priority
        , p_subinventory               => p_subinventory
        , p_trip_stop_id               => p_trip_stop_id
        , p_delivery_id                => p_delivery_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_locator_id                 => p_locator_id
        , p_lot_number                 => p_lot_number
        , p_revision                   => p_revision
        , p_org_id                     => p_org_id
        , x_hash_value                 => l_hash_value
        , x_insert_key_rec             => l_insert_key_rec
        , x_error_message              => x_error_message
        , p_dest_subinventory          => p_dest_subinventory
        , p_dest_locator_id            => p_dest_locator_id
        , p_project_id                 => p_project_id
        , p_task_id                    => p_task_id
        );
        insert_key(
          l_hash_value                 => l_hash_value
        , l_insert_key_rec             => l_insert_key_rec
        , x_pick_slip_number           => x_pick_slip_number
        , x_error_message              => x_error_message
        );
      END IF;

      x_api_status                                 := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    -- Comes here only if l_found is TRUE. (Grouping Rule is already cached)
    -- (ie) Rule is Found. But Pick Slip Number may not yet be generated.

    create_hash(
      p_rule_index                 => l_rule_index
    , p_header_id                  => p_header_id
    , p_customer_id                => p_customer_id
    , p_ship_method_code           => p_ship_method_code
    , p_ship_to_loc_id             => p_ship_to_loc_id
    , p_shipment_priority          => p_shipment_priority
    , p_subinventory               => p_subinventory
    , p_trip_stop_id               => p_trip_stop_id
    , p_delivery_id                => p_delivery_id
    , p_inventory_item_id          => p_inventory_item_id
    , p_locator_id                 => p_locator_id
    , p_lot_number                 => p_lot_number
    , p_revision                   => p_revision
    , p_org_id                     => p_org_id
    , x_hash_value                 => l_hash_value
    , x_insert_key_rec             => l_insert_key_rec
    , x_error_message              => x_error_message
    , p_dest_subinventory          => p_dest_subinventory
    , p_dest_locator_id            => p_dest_locator_id
    , p_project_id                 => p_project_id
    , p_task_id                    => p_task_id
    );

    IF g_pskey_table.EXISTS(l_hash_value) THEN
      -- Pick Slip Number already exists.
      x_pick_slip_number                   := g_pskey_table(l_hash_value).pick_slip_number;
      g_pskey_table(l_hash_value).counter  := g_pskey_table(l_hash_value).counter + 1;

      -- Print is immediate so check if limit has been reached
      IF (p_ps_mode = 'I' AND l_limit <> -1) THEN
        IF (g_pskey_table(l_hash_value).counter >= l_limit) THEN
          x_ready_to_print := fnd_api.g_true;
          wsh_pr_pick_slip_number.g_print_ps_table(wsh_pr_pick_slip_number.g_print_ps_table.COUNT + 1) :=
            x_pick_slip_number;
          g_pskey_table.DELETE(l_hash_value);
        END IF;
      END IF;
    ELSE
      -- Pick Slip Number doesnt exists. Insert a new one.
      insert_key(
        l_hash_value                 => l_hash_value
      , l_insert_key_rec             => l_insert_key_rec
      , x_pick_slip_number           => x_pick_slip_number
      , x_error_message              => x_error_message
      );
    END IF;

    x_api_status      := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_NUMBER.GET_PICK_SLIP_NUMBER';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.GET_PICK_SLIP_NUMBER',3);
      END IF;
      x_api_status     := fnd_api.g_ret_sts_unexp_error;
  END get_pick_slip_number;

  /***********************************************************************************************
  *                                                                                              *
  *                             Component Picking Related Procedures                             *
  *                                                                                              *
  ***********************************************************************************************/

  --
  -- Name
  --   PROCEDURE INSERT_KEY
  --
  -- Purpose
  --   Insert new key to table and returns newly generated Pick Slip Number
  --   This procedure is used by WIP GET_PICK_SLIP_NUMBER Procedure.
  --

  PROCEDURE insert_key
  ( l_hash_value        IN   NUMBER
  , l_insert_key_rec    IN   wipkeyrectyp
  , x_pick_slip_number  OUT  NOCOPY  NUMBER
  , x_error_message     OUT  NOCOPY  VARCHAR2
  ) IS
  BEGIN
    SELECT wsh_pick_slip_numbers_s.NEXTVAL
      INTO x_pick_slip_number
      FROM DUAL;

    g_wip_pskey_table(l_hash_value)                   := l_insert_key_rec;
    g_wip_pskey_table(l_hash_value).pick_slip_number  := x_pick_slip_number;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_NUMBER.INSERT_KEY';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.INSERT_KEY',3);
      END IF;
  END insert_key;

  --
  -- Name
  --   PROCEDURE CREATE_HASH
  --
  -- Purpose
  --   Generate a hash value for the given values for the column strings.
  --   This procedure is used by WIP GET_PICK_SLIP_NUMBER Procedure.
  --
  -- Input Parameter
  --   p_rule_index            => Index to the Grouping Rule Table
  --   p_org_id                => Organization ID
  --   p_wip_entity_id         => WIP Entity ID
  --   p_rep_schedule_id       => Repetitive Schedule ID
  --   p_operation_seq_num     => Operation Sequence Number
  --   p_dept_id               => Department ID
  --   p_push_or_pull          => Push or Pull
  --   p_supply_subinventory   => Supply SubInventory
  --   p_supply_locator_id     => Supply Locator ID
  --   p_project_id            => Project ID
  --   p_task_id               => Task ID
  --   p_src_subinventory      => Source SubInventory
  --   p_src_locator_id        => Source Locator ID
  --   p_inventory_item_id     => Inventory Item ID
  --   p_revision              => Revision
  --   p_lot_number            => Lot Number
  --   p_dest_subinventory     => Destination Subinventory
  --   p_dest_locator_id       => Destination Locator Id
  --   p_project_id            => Project Id
  --   p_task_id               => Task Id
  --
  -- Output Parameter
  --   x_hash_value            => Hash Value for g_wip_pskey_table
  --   x_insert_key_rec        => WIPKeyRecTyp
  --   x_error_message         => Error message
  --

  PROCEDURE create_hash(
    p_rule_index          IN     NUMBER
  , p_org_id              IN     NUMBER
  , p_wip_entity_id       IN     NUMBER
  , p_rep_schedule_id     IN     NUMBER
  , p_operation_seq_num   IN     NUMBER
  , p_dept_id             IN     NUMBER
  , p_push_or_pull        IN     VARCHAR2
  , p_supply_subinventory IN     VARCHAR2
  , p_supply_locator_id   IN     NUMBER
  , p_project_id          IN     NUMBER
  , p_task_id             IN     NUMBER
  , p_src_subinventory    IN     VARCHAR2
  , p_src_locator_id      IN     NUMBER
  , p_inventory_item_id   IN     NUMBER
  , p_revision            IN     VARCHAR2
  , p_lot_number          IN     VARCHAR2
  , x_hash_value          OUT    NOCOPY NUMBER
  , x_insert_key_rec      OUT    NOCOPY wipkeyrectyp
  , x_error_message       OUT    NOCOPY VARCHAR2
  ) IS
    l_hash_string VARCHAR2(2000) := NULL;
  BEGIN
    l_hash_string                      := TO_CHAR(g_rule_table(p_rule_index).grouping_rule_id);
    x_insert_key_rec.grouping_rule_id  := g_rule_table(p_rule_index).grouping_rule_id;

    IF (g_rule_table(p_rule_index).use_jobsch_ps = 'Y') THEN
      l_hash_string                     := l_hash_string || '-' || TO_CHAR(p_wip_entity_id) || '-' || TO_CHAR(p_rep_schedule_id);
      x_insert_key_rec.wip_entity_id    := p_wip_entity_id;
      x_insert_key_rec.rep_schedule_id  := p_rep_schedule_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_oper_seq_ps = 'Y') THEN
      l_hash_string                       := l_hash_string || '-' || TO_CHAR(p_operation_seq_num);
      x_insert_key_rec.operation_seq_num  := p_operation_seq_num;
    END IF;

    IF (g_rule_table(p_rule_index).use_dept_ps = 'Y') THEN
      l_hash_string             := l_hash_string || '-' || TO_CHAR(p_dept_id);
      x_insert_key_rec.dept_id  := p_dept_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_supply_type_ps = 'Y') THEN
      l_hash_string                  := l_hash_string || '-' || p_push_or_pull;
      x_insert_key_rec.push_or_pull  := p_push_or_pull;
    END IF;

    IF (g_rule_table(p_rule_index).use_supply_sub_ps = 'Y') THEN
      l_hash_string                         := l_hash_string || '-' || p_supply_subinventory;
      x_insert_key_rec.supply_subinventory  := p_supply_subinventory;
    END IF;

    IF (g_rule_table(p_rule_index).use_supply_loc_ps = 'Y') THEN
      l_hash_string                       := l_hash_string || '-' || TO_CHAR(p_supply_locator_id);
      x_insert_key_rec.supply_locator_id  := p_supply_locator_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_project_ps = 'Y') THEN
      l_hash_string                := l_hash_string || '-' || TO_CHAR(p_project_id);
      x_insert_key_rec.project_id  := p_project_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_task_ps = 'Y') THEN
      l_hash_string             := l_hash_string || '-' || TO_CHAR(p_task_id);
      x_insert_key_rec.task_id  := p_task_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_src_sub_ps = 'Y') THEN
      l_hash_string                      := l_hash_string || '-' || p_src_subinventory;
      x_insert_key_rec.src_subinventory  := p_src_subinventory;
    END IF;

    IF (g_rule_table(p_rule_index).use_src_locator_ps = 'Y') THEN
      l_hash_string                    := l_hash_string || '-' || TO_CHAR(p_src_locator_id);
      x_insert_key_rec.src_locator_id  := p_src_locator_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_item_ps = 'Y') THEN
      l_hash_string                       := l_hash_string || '-' || TO_CHAR(p_inventory_item_id);
      x_insert_key_rec.inventory_item_id  := p_inventory_item_id;
    END IF;

    IF (g_rule_table(p_rule_index).use_lot_ps = 'Y') THEN
      l_hash_string                := l_hash_string || '-' || p_lot_number;
      x_insert_key_rec.lot_number  := p_lot_number;
    END IF;

    IF (g_rule_table(p_rule_index).use_revision_ps = 'Y') THEN
      l_hash_string              := l_hash_string || '-' || p_revision;
      x_insert_key_rec.revision  := p_revision;
    END IF;

    x_insert_key_rec.organization_id   := p_org_id;
    l_hash_string                      := l_hash_string || '-' || TO_CHAR(p_org_id);
    x_hash_value                       := DBMS_UTILITY.get_hash_value(NAME => l_hash_string, base => g_hash_base, hash_size => g_hash_size);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_NUMBER.CREATE_HASH';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.CREATE_HASH',3);
      END IF;
  END create_hash;

  --
  -- Name
  --   PROCEDURE GET_PICK_SLIP_NUMBER (Used by Component Picking (WIP))
  --
  -- Purpose
  --   Returns Pick Slip Number. This overloaded procedure is used for WIP.
  --
  -- Input Parameters
  --   p_pick_grouping_rule_id => Pick Grouping Rule ID
  --   p_org_id                => Organization ID
  --   p_wip_entity_id         => WIP Entity ID
  --   p_rep_schedule_id       => Repetitive Schedule ID
  --   p_operation_seq_num     => Operation Sequence Number
  --   p_dept_id               => Department ID
  --   p_push_or_pull          => Push or Pull
  --   p_supply_subinventory   => Supply SubInventory
  --   p_supply_locator_id     => Supply Locator ID
  --   p_project_id            => Project ID
  --   p_task_id               => Task ID
  --   p_src_subinventory      => Source SubInventory
  --   p_src_locator_id        => Source Locator ID
  --   p_inventory_item_id     => Inventory Item ID
  --   p_revision              => Revision
  --   p_lot_number            => Lot Number
  --
  -- Output Parameters
  --   x_pick_slip_number      => Pick Slip Number
  --   x_api_status            => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_error_message         => Error message
  --
  PROCEDURE get_pick_slip_number(
    p_pick_grouping_rule_id IN     NUMBER
  , p_org_id                IN     NUMBER
  , p_wip_entity_id         IN     NUMBER
  , p_rep_schedule_id       IN     NUMBER
  , p_operation_seq_num     IN     NUMBER
  , p_dept_id               IN     NUMBER
  , p_push_or_pull          IN     VARCHAR2
  , p_supply_subinventory   IN     VARCHAR2
  , p_supply_locator_id     IN     NUMBER
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  , p_src_subinventory      IN     VARCHAR2
  , p_src_locator_id        IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_revision              IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , x_pick_slip_number      OUT    NOCOPY NUMBER
  , x_api_status            OUT    NOCOPY VARCHAR2
  , x_error_message         OUT    NOCOPY VARCHAR2
) IS
    -- cursor to get the pick slip grouping rule
    CURSOR ps_rule(v_pgr_id IN NUMBER) IS
      SELECT NVL(job_schedule_flag, 'N')
           , NVL(operation_flag, 'N')
           , NVL(department_flag, 'N')
           , NVL(push_vs_pull_flag, 'N')
           , NVL(dest_sub_flag, 'N')
           , NVL(dest_loc_flag, 'N')
           , NVL(project_flag, 'N')
           , NVL(task_flag, 'N')
           , NVL(subinventory_flag, 'N')
           , NVL(locator_flag, 'N')
           , NVL(item_flag, 'N')
           , NVL(revision_flag, 'N')
           , NVL(lot_flag, 'N')
           , NVL(pick_method, '-99')
        FROM wsh_pick_grouping_rules
       WHERE pick_grouping_rule_id = v_pgr_id;

    l_insert_key_rec wipkeyrectyp;
    l_hash_value     NUMBER;
    l_rule_index     NUMBER;
    l_found          BOOLEAN;
  BEGIN
    -- l_found is used to determine whether Grouping Rule exists in Rule Table.
    l_found       := FALSE;

    IF g_rule_table.EXISTS(p_pick_grouping_rule_id) THEN
      l_found       := TRUE;
      l_rule_index  := p_pick_grouping_rule_id;
    END IF;

    IF ((l_found) AND (g_rule_table(l_rule_index).pick_method = g_cluster_pick_method)) THEN
      /* Cluster Picking:
           Do not store the pick slip numbers generated, as a new one is required for each line. */
      SELECT wsh_pick_slip_numbers_s.NEXTVAL
        INTO x_pick_slip_number
        FROM DUAL;

      x_api_status  := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    -- Rule is not found. Fetch the attributes concerning the Pick Slip Grouping Rule
    IF (NOT l_found) THEN
      l_rule_index := p_pick_grouping_rule_id;
      OPEN ps_rule(p_pick_grouping_rule_id);
      FETCH ps_rule INTO g_rule_table(l_rule_index).use_jobsch_ps
                       , g_rule_table(l_rule_index).use_oper_seq_ps
                       , g_rule_table(l_rule_index).use_dept_ps
                       , g_rule_table(l_rule_index).use_supply_type_ps
                       , g_rule_table(l_rule_index).use_supply_sub_ps
                       , g_rule_table(l_rule_index).use_supply_loc_ps
                       , g_rule_table(l_rule_index).use_project_ps
                       , g_rule_table(l_rule_index).use_task_ps
                       , g_rule_table(l_rule_index).use_src_sub_ps
                       , g_rule_table(l_rule_index).use_src_locator_ps
                       , g_rule_table(l_rule_index).use_item_ps
                       , g_rule_table(l_rule_index).use_revision_ps
                       , g_rule_table(l_rule_index).use_lot_ps
                       , g_rule_table(l_rule_index).pick_method;

      IF ps_rule%NOTFOUND THEN
        x_error_message  := 'Pick grouping rule ' || TO_CHAR(p_pick_grouping_rule_id) || ' does not exist';
        x_api_status     := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;

      g_rule_table(l_rule_index).grouping_rule_id  := p_pick_grouping_rule_id;

      -- Rule Table is cached with the Rule and the Attributes. Now PickSlip Number has to be Generated.

      IF (g_rule_table(l_rule_index).pick_method = g_cluster_pick_method) THEN
        /* Cluster Picking:
             Do not store the pick slip numbers generated, as a new one is required for each line. */
        SELECT wsh_pick_slip_numbers_s.NEXTVAL
          INTO x_pick_slip_number
          FROM DUAL;
      ELSE
        -- Generate a new PickSlip Number and Insert it for future use.
        create_hash(
          p_rule_index                 => l_rule_index
        , p_org_id                     => p_org_id
        , p_wip_entity_id              => p_wip_entity_id
        , p_rep_schedule_id            => p_rep_schedule_id
        , p_operation_seq_num          => p_operation_seq_num
        , p_dept_id                    => p_dept_id
        , p_push_or_pull               => p_push_or_pull
        , p_supply_subinventory        => p_supply_subinventory
        , p_supply_locator_id          => p_supply_locator_id
        , p_project_id                 => p_project_id
        , p_task_id                    => p_task_id
        , p_src_subinventory           => p_src_subinventory
        , p_src_locator_id             => p_src_locator_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_revision                   => p_revision
        , p_lot_number                 => p_lot_number
        , x_hash_value                 => l_hash_value
        , x_insert_key_rec             => l_insert_key_rec
        , x_error_message              => x_error_message
        );
        insert_key(
          l_hash_value                 => l_hash_value
        , l_insert_key_rec             => l_insert_key_rec
        , x_pick_slip_number           => x_pick_slip_number
        , x_error_message              => x_error_message
        );
      END IF;

      x_api_status := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    -- Comes here only if l_found is TRUE. (Grouping Rule is already cached)
    -- (ie) Rule is Found. But Pick Slip Number may not yet be generated.

    create_hash(
      p_rule_index                 => l_rule_index
    , p_org_id                     => p_org_id
    , p_wip_entity_id              => p_wip_entity_id
    , p_rep_schedule_id            => p_rep_schedule_id
    , p_operation_seq_num          => p_operation_seq_num
    , p_dept_id                    => p_dept_id
    , p_push_or_pull               => p_push_or_pull
    , p_supply_subinventory        => p_supply_subinventory
    , p_supply_locator_id          => p_supply_locator_id
    , p_project_id                 => p_project_id
    , p_task_id                    => p_task_id
    , p_src_subinventory           => p_src_subinventory
    , p_src_locator_id             => p_src_locator_id
    , p_inventory_item_id          => p_inventory_item_id
    , p_revision                   => p_revision
    , p_lot_number                 => p_lot_number
    , x_hash_value                 => l_hash_value
    , x_insert_key_rec             => l_insert_key_rec
    , x_error_message              => x_error_message
    );

    IF g_wip_pskey_table.EXISTS(l_hash_value) THEN
      -- Pick Slip Number already exists.
       x_pick_slip_number  := g_wip_pskey_table(l_hash_value).pick_slip_number;
    ELSE
      -- Pick Slip Number doesnt exists. Insert a new one.
      insert_key(
        l_hash_value                 => l_hash_value
      , l_insert_key_rec             => l_insert_key_rec
      , x_pick_slip_number           => x_pick_slip_number
      , x_error_message              => x_error_message
      );
    END IF;
    x_api_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_NUMBER.GET_PICK_SLIP_NUMBER';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.GET_PICK_SLIP_NUMBER',3);
      END IF;
      x_api_status     := fnd_api.g_ret_sts_unexp_error;
  END get_pick_slip_number;

  --
  -- Name
  --   PROCEDURE PRINT_PICK_SLIP (Used by Component Picking (WIP))
  --
  -- Purpose
  --   Submits the Concurrent Request to print the Move Order Pick Slip Report.
  --
  -- Input Parameters
  --   p_organization_id       => Organization ID
  --   p_mo_request_number     => Move Order Request Number
  --
  -- Output Parameters
  --   x_request_id            => Concurrent Request ID
  --   x_return_status         => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_msg_data              => Error Messages
  --   x_msg_count             => Error Messages Count
  FUNCTION print_pick_slip(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_organization_id         NUMBER
  , p_mo_request_number       NUMBER
  , p_plan_tasks              BOOLEAN
  ) RETURN NUMBER IS
    l_request_id NUMBER;
    l_plan_tasks VARCHAR2(1) := 'N';
  BEGIN
    IF p_plan_tasks THEN
       l_plan_tasks := 'Y';
    END IF;
    l_request_id  := inv_pick_slip_report.print_pick_slip(
                       p_organization_id => p_organization_id
                     , p_move_order_from => p_mo_request_number
                     , p_move_order_to   => p_mo_request_number
                     , p_plan_tasks      => l_plan_tasks
                     );

    IF l_request_id = 0 THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded=>fnd_api.g_false,p_data=>x_msg_data, p_count=>x_msg_count);
    ELSE
       x_return_status := fnd_api.g_ret_sts_success;
    END IF;

    RETURN l_request_id;
  END print_pick_slip;

  --
  -- Name
  --   PROCEDURE DELETE_WIP_PS_TBL
  --
  -- Purpose
  --   Deletes the global PL/SQL table used to store pick slip numbers
  --   This is called at the end of component pick release
  --
  -- Input Parameters
  --   None
  --
  -- Output Parameters
  --   None
  PROCEDURE delete_wip_ps_tbl IS
  BEGIN
    g_wip_pskey_table.DELETE;
  EXCEPTION
    WHEN OTHERS THEN
      inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.DELETE_WIP_PS_TBL', 3);
  END delete_wip_ps_tbl;

 -- /* For Parallel Pick-Release */
  -- Name
  --   PROCEDURE CREATE_PICK_SLIP_STRING
  --
  -- Purpose
  --   Generate a hash value for the given values for the column strings.
  --   This procedure is used by Shipping GET_PICK_SLIP_NUMBER_PARALLEL Procedure.
  --
  -- Input Parameter
  --   p_rule_index         => Index to the Grouping Rule Table
  --   p_header_id          => Order Header ID
  --   p_customer_id        => Customer ID
  --   p_ship_method_code   => Ship Method
  --   p_ship_to_loc_id     => Ship to Location
  --   p_shipment_priority  => Shipment Priority
  --   p_subinventory       => SubInventory
  --   p_trip_stop_id       => Trip Stop
  --   p_delivery_id        => Delivery
  --   p_inventory_item_id  => Item
  --   p_locator_id         => Locator
  --   p_lot_number         => Lot Number
  --   p_revision           => Revision
  --   p_org_id             => Organization
  --   p_dest_subinventory     => Destination Subinventory
  --   p_dest_locator_id       => Destination Locator Id
  --   p_project_id            => Project Id
  --   p_task_id               => Task Id

  --
  -- Output Parameter
  --   x_hash_string        => Hash string to insert into mtl_pick_slip_numbers
  --   x_error_message      => Error message
  --

  PROCEDURE create_pick_slip_string(
    p_rule_index        IN     NUMBER
  , p_header_id         IN     NUMBER
  , p_customer_id       IN     NUMBER
  , p_ship_method_code  IN     VARCHAR2
  , p_ship_to_loc_id    IN     NUMBER
  , p_shipment_priority IN     VARCHAR2
  , p_subinventory      IN     VARCHAR2
  , p_trip_stop_id      IN     NUMBER
  , p_delivery_id       IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_locator_id        IN     NUMBER
  , p_lot_number        IN     VARCHAR2
  , p_revision          IN     VARCHAR2
  , p_org_id            IN     NUMBER
  , x_error_message     OUT    NOCOPY VARCHAR2
  , x_hash_string	IN OUT NOCOPY VARCHAR2
  , p_dest_subinventory IN     VARCHAR2 DEFAULT NULL
  , p_dest_locator_id   IN     NUMBER   DEFAULT NULL
  , p_project_id        IN     NUMBER   DEFAULT NULL
  , p_task_id           IN     NUMBER   DEFAULT NULL
) IS
    l_batch_id    NUMBER	:= WSH_PICK_LIST.G_BATCH_ID;
    l_hash_string VARCHAR2(2000);
  BEGIN

    l_hash_string := TO_CHAR(l_batch_id) || '-' || TO_CHAR(g_rule_table(p_rule_index).grouping_rule_id);

    IF (g_rule_table(p_rule_index).use_order_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_header_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_customer_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_customer_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_carrier_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || p_ship_method_code;
    END IF;

    IF (g_rule_table(p_rule_index).use_ship_to_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_ship_to_loc_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_ship_priority_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || p_shipment_priority;
    END IF;

    IF (g_rule_table(p_rule_index).use_trip_stop_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_trip_stop_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_delivery_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_delivery_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_src_sub_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || p_subinventory;
    END IF;

    IF (g_rule_table(p_rule_index).use_src_locator_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_locator_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_item_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_inventory_item_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_lot_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || p_lot_number;
    END IF;

    IF (g_rule_table(p_rule_index).use_revision_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || p_revision;
    END IF;

    IF (g_rule_table(p_rule_index).use_supply_sub_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || p_dest_subinventory;
    END IF;

    IF (g_rule_table(p_rule_index).use_supply_loc_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_dest_locator_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_project_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_project_id);
    END IF;

    IF (g_rule_table(p_rule_index).use_task_ps = 'Y') THEN
      l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_task_id);
    END IF;

    l_hash_string	:= l_hash_string || '-' || TO_CHAR(p_org_id);
    x_hash_string	:= l_hash_string;

EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_NUMBER.CREATE_PICK_SLIP_STRING';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.CREATE_PICK_SLIP_STRING',3);
      END IF;
END create_pick_slip_string;

  -- /* For Parallel Pick-Release */
  -- Name
  --   PROCEDURE GEN_PARALLEL_PICK_SLIP_NUMBER
  --
  -- Purpose
  --   Insert a new row with the new pick_slip_number generated or
  --   update the table record for count. Table: MTL_PICK_SLIP_NUMBERS
  --   This procedure is used by Shipping GET_PICK_SLIP_NUMBER_PARALLEL Procedure.
  --

PROCEDURE gen_parallel_pick_slip_number
( p_hash_string       IN          VARCHAR2
, p_limit             IN          NUMBER
, x_pick_slip_number  OUT NOCOPY  NUMBER
, x_error_message     OUT NOCOPY  VARCHAR2
, x_api_status        OUT NOCOPY  VARCHAR2
, x_pick_slip_status  OUT NOCOPY  NUMBER
) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_debug             NUMBER;
  l_batch_id          NUMBER  := WSH_PICK_LIST.G_BATCH_ID;
  l_pick_slip_status  NUMBER;
  l_pick_slip_count   NUMBER;
  l_pick_slip_number  NUMBER;
  l_num_attempts      NUMBER;
  l_max_attempts      NUMBER;
  l_success           BOOLEAN;

  unique_constraint_exc  EXCEPTION;
  PRAGMA EXCEPTION_INIT  (unique_constraint_exc, -1);
  wait_timeout_exc       EXCEPTION;
  PRAGMA EXCEPTION_INIT  (wait_timeout_exc, -30006);

BEGIN
  x_api_status := fnd_api.g_ret_sts_success;
  l_debug      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  IF (l_debug = 1) THEN
     inv_log_util.trace('p_hash_string = ' || p_hash_string,
        'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
     inv_log_util.trace('p_limit = ' || p_limit,
        'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
  END IF;

  l_success          := FALSE;
  l_num_attempts     := 1;
  l_max_attempts     := 3;
  l_pick_slip_status := 1;
  l_pick_slip_count  := 0;
  l_pick_slip_number := NULL;

  -- Make "l_max_attempts" iterations to either INSERT or lock a record
  -- in MTL_PICK_SLIP_NUMBERS
  WHILE (l_num_attempts <= l_max_attempts AND (NOT l_success))
  LOOP
  -- {
     -- begin
     --    try insert
     -- exception -00001 (unique constraint violated)
     --    begin
     --       select for update, wait 5 seconds
     --    exception -30006 (timeout)
     --       retry insert
     --    exception no_data_found (pick slip STATUS updated to 2 by locking process)
     --       retry insert
     --    exception others
     --       exit loop
     -- exception others
     --    exit loop
     IF (l_debug = 1) THEN
        inv_log_util.trace('l_num_attempts = ' || l_num_attempts,
           'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
     END IF;
     BEGIN
        INSERT INTO mtl_pick_slip_numbers
        ( id
        , pick_slip_batch_id
        , pick_slip_count
        , pick_slip_identifier
        , pick_slip_number
        , status
        ) VALUES ( mtl_pick_slip_numbers_s.nextval
                 , l_batch_id
                 , l_pick_slip_count
                 , p_hash_string
                 , wsh_pick_slip_numbers_s.nextval
                 , l_pick_slip_status
                 )
         RETURNING pick_slip_number
              INTO l_pick_slip_number;

        IF (l_debug = 1) THEN
           inv_log_util.trace('Inserted pick slip # ' || l_pick_slip_number,
              'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
        END IF;
        l_success := TRUE;
     EXCEPTION
     -- {
        WHEN unique_constraint_exc THEN
           IF (l_debug = 1) THEN
              inv_log_util.trace('INSERT failed, row already exists',
                 'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
           END IF;
           BEGIN
              SELECT pick_slip_number
                   , pick_slip_count
                INTO l_pick_slip_number
                   , l_pick_slip_count
                FROM mtl_pick_slip_numbers
               WHERE pick_slip_identifier = p_hash_string
                 AND status = 1
                 FOR UPDATE WAIT 5;

              l_success := TRUE;

              IF (l_debug = 1) THEN
                 inv_log_util.trace('Locked row, pick slip # is ' || l_pick_slip_number
                    || ', pick slip count is ' || l_pick_slip_count,
                    'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
              END IF;
           EXCEPTION
              WHEN wait_timeout_exc THEN
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('Timeout waiting for lock',
                       'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
                 END IF;
                 l_success := FALSE;
              WHEN NO_DATA_FOUND THEN
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('No data found, so retrying INSERT',
                       'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
                 END IF;
                 l_success := FALSE;
              WHEN OTHERS THEN
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('Other exception: ' || sqlerrm,
                       'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
                 END IF;
                 l_success := FALSE;
                 EXIT;
           END;
        WHEN OTHERS THEN
           IF (l_debug = 1) THEN
              inv_log_util.trace('Other exception: ' || sqlerrm,
                 'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
           END IF;
           l_success := FALSE;
           EXIT;
     -- }
     END;
     l_num_attempts := l_num_attempts + 1;
  -- }
  END LOOP;

  IF (NOT l_success) AND l_pick_slip_number IS NULL THEN
     SELECT wsh_pick_slip_numbers_s.nextval
       INTO l_pick_slip_number
       FROM dual;
     l_pick_slip_status := 2;
     IF (l_debug = 1) THEN
        inv_log_util.trace('Failed to INSERT or LOCK pick slip record.  Returning next value: '
           || l_pick_slip_number,
           'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
     END IF;
  ELSE
     IF (l_pick_slip_count + 1) >= p_limit THEN
        l_pick_slip_status := 2;
     END IF;
     UPDATE mtl_pick_slip_numbers
        SET pick_slip_count = pick_slip_count + 1
          , status = l_pick_slip_status
      WHERE pick_slip_identifier = p_hash_string
        AND status = 1
            RETURNING pick_slip_count INTO l_pick_slip_count;
     IF (l_debug = 1) AND SQL%FOUND THEN
        inv_log_util.trace('Updated count to ' || l_pick_slip_count ||
           ', status to ' || l_pick_slip_status,
           'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER', 3);
     END IF;
  END IF;

  COMMIT;

  x_pick_slip_number := l_pick_slip_number;
  x_pick_slip_status := l_pick_slip_status;

EXCEPTION
  WHEN OTHERS THEN
     x_error_message := 'Error occurred in GEN_PARALLEL_PICK_SLIP_NUMBER';
     x_api_status := fnd_api.g_ret_sts_unexp_error;
     IF (l_debug = 1) THEN
        inv_log_util.trace('Exception: ' || SQLERRM,
           'INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER',3);
     END IF;
END gen_parallel_pick_slip_number;


  -- /* For Parallel Pick-Release */
  -- Name
  --   PROCEDURE GET_PICK_SLIP_NUMBER_PARALLEL (Used by Shipping)
  --
  -- Purpose
  --   Returns Pick Slip Number and whether a Pick Slip should be printed. This
  --   overloaded procedure is used by Shipping for Parallel Pick Release.
  --
  -- Input Parameters
  --   p_ps_mode               => Pick Slip Print Mode: I = Immediate, E = Deferred
  --   p_pick_grouping_rule_id => Pick Grouping Rule ID
  --   p_org_id                => Organization ID
  --   p_header_id             => Order Header ID
  --   p_customer_id           => Customer ID
  --   p_ship_method_code      => Ship Method
  --   p_ship_to_loc_id        => Ship to Location
  --   p_shipment_priority     => Shipment Priority
  --   p_subinventory          => SubInventory
  --   p_trip_stop_id          => Trip Stop
  --   p_delivery_id           => Delivery
  --   p_inventory_item_id     => Inventory Item ID
  --   p_locator_id            => Locator ID
  --   p_lot_number            => Lot Number
  --   p_revision              => Revision
  --   p_dest_subinventory     => Destination Subinventory
  --   p_dest_locator_id       => Destination Locator Id
  --   p_project_id            => Project Id
  --   p_task_id               => Task Id

  --
  -- Output Parameters
  --   x_pick_slip_number      => Pick Slip Number
  --   x_ready_to_print        => FND_API.G_TRUE or FND_API.G_FALSE
  --   x_api_status            => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_error_message         => Error message

PROCEDURE get_pick_slip_number_parallel(
    p_ps_mode               IN     VARCHAR2
  , p_pick_grouping_rule_id IN     NUMBER
  , p_org_id                IN     NUMBER
  , p_header_id             IN     NUMBER
  , p_customer_id           IN     NUMBER
  , p_ship_method_code      IN     VARCHAR2
  , p_ship_to_loc_id        IN     NUMBER
  , p_shipment_priority     IN     VARCHAR2
  , p_subinventory          IN     VARCHAR2
  , p_trip_stop_id          IN     NUMBER
  , p_delivery_id           IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_locator_id            IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_revision              IN     VARCHAR2
  , x_pick_slip_number      OUT    NOCOPY NUMBER
  , x_ready_to_print        OUT    NOCOPY VARCHAR2
  , x_call_mode             OUT    NOCOPY VARCHAR2
  , x_api_status            OUT    NOCOPY VARCHAR2
  , x_error_message         OUT    NOCOPY VARCHAR2
  , p_dest_subinventory     IN     VARCHAR2
  , p_dest_locator_id       IN     NUMBER
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  ) IS
    -- cursor to get the pick slip grouping rule
    CURSOR ps_rule(v_pgr_id IN NUMBER) IS
      SELECT NVL(order_number_flag, 'N')
           , NVL(customer_flag, 'N')
           , NVL(ship_to_flag, 'N')
           , NVL(carrier_flag, 'N')
           , NVL(shipment_priority_flag, 'N')
           , NVL(trip_stop_flag, 'N')
           , NVL(delivery_flag, 'N')
           , NVL(subinventory_flag, 'N')
           , NVL(locator_flag, 'N')
           , NVL(dest_sub_flag, 'N')
           , NVL(dest_loc_flag, 'N')
           , NVL(project_flag, 'N')
           , NVL(task_flag, 'N')
           , NVL(item_flag, 'N')
           , NVL(revision_flag, 'N')
           , NVL(lot_flag, 'N')
           , NVL(pick_method, '-99')
        FROM wsh_pick_grouping_rules
       WHERE pick_grouping_rule_id = v_pgr_id;
    -- cursor to get number of times called before printer
    CURSOR get_limit(v_org_id IN NUMBER) IS
      SELECT NVL(pick_slip_lines, -1)
        FROM wsh_shipping_parameters
       WHERE organization_id = v_org_id;

    l_limit          NUMBER;
    l_insert_key_rec keyrectyp;
    l_hash_string VARCHAR2(2000) := NULL;
    l_rule_index     NUMBER;
    l_found		BOOLEAN;
    l_pick_slip_status  NUMBER;
  BEGIN
    IF (wsh_pick_list.g_batch_id IS NOT NULL) THEN
      -- Needed for inventory to know whether this API is triggered Manually or thru Pick Release
      x_call_mode  := 'Y';
    END IF;

    IF p_ps_mode = 'I' THEN
      IF p_org_id = g_prev_org_id THEN
        l_limit  := g_pickslip_limit;
      ELSE
        OPEN get_limit(p_org_id);
        FETCH get_limit INTO l_limit;

        IF get_limit%NOTFOUND THEN
          x_error_message  := 'Organization ' || TO_CHAR(p_org_id) || ' does not exist. ';
          x_api_status     := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;

        g_prev_org_id     := p_org_id;
        g_pickslip_limit  := l_limit;
      END IF;
    END IF;

    -- Set ready to print flag to FALSE initially
    x_ready_to_print  := fnd_api.g_false;

    IF (p_ps_mode = 'I' AND l_limit = 1) THEN
      SELECT wsh_pick_slip_numbers_s.NEXTVAL
      INTO x_pick_slip_number
      FROM dual;
      wsh_pr_pick_slip_number.g_print_ps_table(wsh_pr_pick_slip_number.g_print_ps_table.COUNT + 1) :=
        x_pick_slip_number;
      x_ready_to_print :=  FND_API.G_TRUE;
      x_api_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    l_found           := FALSE;

    IF g_rule_table.EXISTS(p_pick_grouping_rule_id) THEN
      l_found       := TRUE;
      l_rule_index  := p_pick_grouping_rule_id;
    END IF;

    IF (NOT l_found) THEN
      l_rule_index := p_pick_grouping_rule_id;
      OPEN ps_rule(p_pick_grouping_rule_id);
      FETCH ps_rule INTO g_rule_table(l_rule_index).use_order_ps
                       , g_rule_table(l_rule_index).use_customer_ps
                       , g_rule_table(l_rule_index).use_ship_to_ps
                       , g_rule_table(l_rule_index).use_carrier_ps
                       , g_rule_table(l_rule_index).use_ship_priority_ps
                       , g_rule_table(l_rule_index).use_trip_stop_ps
                       , g_rule_table(l_rule_index).use_delivery_ps
                       , g_rule_table(l_rule_index).use_src_sub_ps
                       , g_rule_table(l_rule_index).use_src_locator_ps
                       , g_rule_table(l_rule_index).use_supply_sub_ps
                       , g_rule_table(l_rule_index).use_supply_loc_ps
                       , g_rule_table(l_rule_index).use_project_ps
                       , g_rule_table(l_rule_index).use_task_ps
                       , g_rule_table(l_rule_index).use_item_ps
                       , g_rule_table(l_rule_index).use_revision_ps
                       , g_rule_table(l_rule_index).use_lot_ps
                       , g_rule_table(l_rule_index).pick_method;

      IF ps_rule%NOTFOUND THEN
        x_error_message  := 'Pick grouping rule ' || TO_CHAR(p_pick_grouping_rule_id) || ' does not exist';
        x_api_status     := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;

      g_rule_table(l_rule_index).grouping_rule_id  := p_pick_grouping_rule_id;
    END IF;

    IF (g_rule_table(l_rule_index).pick_method = g_cluster_pick_method) THEN
      SELECT wsh_pick_slip_numbers_s.NEXTVAL
        INTO x_pick_slip_number
        FROM DUAL;

      x_api_status  := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

   create_pick_slip_string(
      p_rule_index                 => l_rule_index
    , p_header_id                  => p_header_id
    , p_customer_id                => p_customer_id
    , p_ship_method_code           => p_ship_method_code
    , p_ship_to_loc_id             => p_ship_to_loc_id
    , p_shipment_priority          => p_shipment_priority
    , p_subinventory               => p_subinventory
    , p_trip_stop_id               => p_trip_stop_id
    , p_delivery_id                => p_delivery_id
    , p_inventory_item_id          => p_inventory_item_id
    , p_locator_id                 => p_locator_id
    , p_lot_number                 => p_lot_number
    , p_revision                   => p_revision
    , p_org_id                     => p_org_id
    , x_error_message              => x_error_message
    , x_hash_string		   => l_hash_string
    , p_dest_subinventory          => p_dest_subinventory
    , p_dest_locator_id            => p_dest_locator_id
    , p_project_id                 => p_project_id
    , p_task_id                    => p_task_id
    );


   gen_parallel_pick_slip_number( p_hash_string		=> l_hash_string
			         ,p_limit		=> l_limit
				 ,x_pick_slip_number	=> x_pick_slip_number
				 ,x_error_message	=> x_error_message
				 ,x_api_status		=> x_api_status
				 ,x_pick_slip_status	=> l_pick_slip_status);

     IF (x_api_status <> fnd_api.g_ret_sts_success) THEN
       x_error_message  := 'Error occurred in INV_PR_PICK_SLIP_NUMBER.GEN_PARALLEL_PICK_SLIP_NUMBER';
       RETURN;
     END IF;

     IF (p_ps_mode = 'I' AND l_limit <> -1) THEN
        IF l_pick_slip_status = 2 THEN
          x_ready_to_print := fnd_api.g_true;
          wsh_pr_pick_slip_number.g_print_ps_table(wsh_pr_pick_slip_number.g_print_ps_table.COUNT + 1) :=
            x_pick_slip_number;
	  --<< check if deletion from the table is required, if so we can delete instead of update >>
        END IF;
      END IF;

    x_api_status      := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_message  := 'Error occurred in INV_PR_PICK_SLIP_NUMBER.GET_PICK_SLIP_NUMBER';
      IF g_trace_on = 1 THEN
         inv_log_util.trace('Exception: ' || SQLERRM,'INV_PR_PICK_SLIP_NUMBER.GET_PICK_SLIP_NUMBER',3);
      END IF;
      x_api_status     := fnd_api.g_ret_sts_unexp_error;

 END get_pick_slip_number_parallel;

END inv_pr_pick_slip_number;

/
