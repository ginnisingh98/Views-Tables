--------------------------------------------------------
--  DDL for Package Body INV_CYC_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CYC_LOVS" AS
/* $Header: INVCYCLB.pls 120.29.12010000.20 2010/07/15 13:51:12 abasheer ship $ */

--  Global constant holding the package name
   G_PKG_NAME CONSTANT VARCHAR2 ( 30 ) := 'INV_CYC_LOVS';
-- Global variables used to store information related to a cycle count entry
   g_count_quantity NUMBER;
   g_count_uom VARCHAR2 ( 3 );
   g_count_secondary_quantity NUMBER;         -- INVCONV, NSRIVAST
   g_count_secondary_uom      VARCHAR2 ( 3 );  -- INVCONV, NSRIVAST
   g_cc_entry CC_ENTRY;
   g_cc_serial_entry CC_SERIAL_ENTRY;
   g_pre_approve_flag VARCHAR2 ( 20 ) := 'FALSE';
   g_serial_out_tolerance BOOLEAN := FALSE;
   g_txn_header_id NUMBER;
   g_txn_proc_mode NUMBER;
   g_user_id NUMBER;
   g_login_id NUMBER;
   g_commit_status_flag NUMBER;
   g_update_flag NUMBER;
   g_insert_flag NUMBER;
   g_serial_number VARCHAR2 ( 30 );
   g_employee_id NUMBER;
   g_employee_full_name VARCHAR2 ( 240 );
-- These two following values correspond to form checkbox values
-- for the current cycle count serial entry used mainly for multiple
-- serial counting
   g_unit_status NUMBER;
   g_system_present NUMBER;
   g_serial_entry_status_code NUMBER;
   g_count_entry_status_code NUMBER;

   /* Bug 4495880-Added the global parameter and defaulted it to FALSE */
    g_condition BOOLEAN := FALSE;
   /* End of fix for Bug 4495880 */
   g_updated_prior BOOLEAN := FALSE;  -- Bug 6371673

   g_lpn_summary_count  BOOLEAN := FALSE ; --9452528.To cehck if this is a summary count or not.


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

   PROCEDURE get_cyc_lov (
      x_cyc_lov   OUT NOCOPY t_genref,
      p_cycle_count IN VARCHAR2,
      p_organization_id IN NUMBER
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      OPEN x_cyc_lov FOR
         SELECT   cycle_count_header_name,
                  cycle_count_header_id,
                  description,
                  inventory_adjustment_account,
                  orientation_code,
                  onhand_visible_flag,
                  zero_count_flag,
                  disable_date,
                  approval_option_code,
                  automatic_recount_flag,
                  unscheduled_count_entry,
                  approval_tolerance_positive,
                  approval_tolerance_negative,
                  cost_tolerance_positive,
                  cost_tolerance_negative,
                  hit_miss_tolerance_positive,
                  hit_miss_tolerance_negative,
                  serial_count_option,
                  serial_detail_option,
                  serial_adjustment_option,
                  serial_discrepancy_option,
                  container_adjustment_option,
                  container_discrepancy_option,
                  container_enabled_flag,
                  cycle_count_type,
                  schedule_empty_locations
         FROM     mtl_cycle_count_headers
         WHERE    organization_id = p_organization_id
         AND      trunc(nvl(disable_date, sysdate+1)) > trunc(sysdate)  --Changed for bug 5519506
         AND      cycle_count_header_name LIKE ( p_cycle_count )
         AND      (     ( cycle_count_header_id IN (
                             SELECT UNIQUE cycle_count_header_id
                             FROM          mtl_cycle_count_entries
                             WHERE         organization_id = p_organization_id
                             AND           entry_status_code IN ( 1, 3 ) )
                        )
                    OR NVL ( unscheduled_count_entry, 2 ) = 1
                  )
         ORDER BY 1;
   END get_cyc_lov;

   PROCEDURE print_debug (
      p_err_msg VARCHAR2
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         inv_mobile_helper_functions.tracelog ( p_err_msg           => p_err_msg,
                                                p_module            => 'INV_CYC_LOVS',
                                                p_level             => 4
                                              );
      END IF;
--   dbms_output.put_line(p_err_msg);
   END print_debug;

-- This will do an autonomous commit to update the
-- cycle count header with the next user count sequence
-- value so that one user does not lock up the entire
-- table when performing a cycle count
   PROCEDURE update_count_list_sequence (
      p_organization_id NUMBER,
      p_cycle_count_header_id NUMBER,
      x_count_list_sequence OUT NOCOPY NUMBER
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_count_list_sequence NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      -- Calculate the next value for the count list sequence
      SELECT NVL ( MAX ( count_list_sequence ), 0 ) + 1
      INTO   l_count_list_sequence
      FROM   mtl_cycle_count_entries
      WHERE  cycle_count_header_id = p_cycle_count_header_id
      AND    organization_id = p_organization_id;

      -- Update this value for the cycle count header
      UPDATE mtl_cycle_count_headers
      SET next_user_count_sequence = l_count_list_sequence + 1
      WHERE  cycle_count_header_id = p_cycle_count_header_id
      AND    organization_id = p_organization_id;

      COMMIT;
      -- Set the output value
      x_count_list_sequence := l_count_list_sequence;
   END update_count_list_sequence;

   PROCEDURE process_entry (
      p_cycle_count_header_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_subinventory IN VARCHAR2,
      p_locator_id IN NUMBER,
      p_parent_lpn_id IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_revision  IN VARCHAR2,
      p_lot_number IN VARCHAR2,
      p_from_serial_number IN VARCHAR2,
      p_to_serial_number IN VARCHAR2,
      p_count_quantity IN NUMBER,
      p_count_uom IN VARCHAR2,
      p_unscheduled_count_entry IN NUMBER,
      p_user_id   IN NUMBER,
      p_cost_group_id IN NUMBER
      ,p_secondary_uom  IN VARCHAR2  -- INVCONV, NSRIVAST
      ,p_secondary_qty  IN NUMBER  -- INVCONV, NSRIVAST

   )
   IS
      l_current_serial VARCHAR2 ( 30 );

      CURSOR cc_entry_cursor
      IS
         SELECT *
         FROM   mtl_cycle_count_entries
         WHERE  cycle_count_header_id = p_cycle_count_header_id
         AND    organization_id = p_organization_id
         AND    subinventory = p_subinventory
         AND    NVL ( locator_id, -99999 ) = NVL ( p_locator_id, -99999 )
         AND    NVL ( parent_lpn_id, -99999 ) = NVL ( p_parent_lpn_id, -99999 )
         AND    inventory_item_id = p_inventory_item_id
         AND    NVL ( revision, '@@@@@' ) = NVL ( p_revision, '@@@@@' )
         AND    NVL ( lot_number, '@@@@@' ) = NVL ( p_lot_number, '@@@@@' )
         AND    NVL ( serial_number, '@@@@@' ) =
                                             NVL ( l_current_serial, '@@@@@' )
         AND    entry_status_code IN ( 1, 3 );

      CURSOR cc_multiple_serial_cursor
      IS
         SELECT *
         FROM   mtl_cycle_count_entries
         WHERE  cycle_count_header_id = p_cycle_count_header_id
         AND    organization_id = p_organization_id
         AND    subinventory = p_subinventory
         AND    NVL ( locator_id, -99999 ) = NVL ( p_locator_id, -99999 )
         AND    NVL ( parent_lpn_id, -99999 ) = NVL ( p_parent_lpn_id, -99999 )
         AND    inventory_item_id = p_inventory_item_id
         AND    NVL ( revision, '@@@@@' ) = NVL ( p_revision, '@@@@@' )
         AND    NVL ( lot_number, '@@@@@' ) = NVL ( p_lot_number, '@@@@@' )
         AND    entry_status_code IN ( 1, 3 );

      CURSOR cc_discrepant_cursor
      IS
         SELECT *
         FROM   mtl_cycle_count_entries
         WHERE  cycle_count_header_id = p_cycle_count_header_id
         AND    organization_id = p_organization_id
         AND    NVL ( parent_lpn_id, -99999 ) = NVL ( p_parent_lpn_id, -99999 )
         AND    inventory_item_id = p_inventory_item_id
         AND    NVL ( revision, '@@@@@' ) = NVL ( p_revision, '@@@@@' )
         AND    NVL ( lot_number, '@@@@@' ) = NVL ( p_lot_number, '@@@@@' )
         AND    NVL ( serial_number, '@@@@@' ) =
                                             NVL ( l_current_serial, '@@@@@' )
         AND    entry_status_code IN ( 1, 3 );

      CURSOR cc_discrepant_multiple_cursor
      IS
         SELECT *
         FROM   mtl_cycle_count_entries
         WHERE  cycle_count_header_id = p_cycle_count_header_id
         AND    organization_id = p_organization_id
         AND    NVL ( parent_lpn_id, -99999 ) = NVL ( p_parent_lpn_id, -99999 )
         AND    inventory_item_id = p_inventory_item_id
         AND    NVL ( revision, '@@@@@' ) = NVL ( p_revision, '@@@@@' )
         AND    NVL ( lot_number, '@@@@@' ) = NVL ( p_lot_number, '@@@@@' )
         AND    entry_status_code IN ( 1, 3 );

-- Bug# 2708133
-- Add this cursor to use for discrepant serials.
-- Note that we don't match against sub, loc, rev, lot, or LPN
-- to allow for location discrepancies as well as rev, lot, and LPN
      CURSOR cc_discrepant_serial_cursor
      IS
         SELECT *
         FROM   mtl_cycle_count_entries
         WHERE  cycle_count_header_id = p_cycle_count_header_id
         AND    organization_id = p_organization_id
         AND    inventory_item_id = p_inventory_item_id
         AND    serial_number = NVL ( l_current_serial, '@@@@@' )
         AND    entry_status_code IN ( 1, 3 );

      l_prefix  VARCHAR2 ( 30 );
      l_quantity NUMBER;
      l_from_number NUMBER;
      l_to_number NUMBER;
      l_errorcode NUMBER;
      l_length  NUMBER;
      l_padded_length NUMBER;
      l_current_number NUMBER;
      l_serial_discrepancy NUMBER;
      l_container_discrepancy NUMBER;
-- Bug# 2386128
-- Don't need this variable anymore
--l_count_list_sequence    NUMBER;
      l_cost_group_id NUMBER;
      l_dispatched_count NUMBER;
      l_dispatched_task NUMBER;
      e_Task_Dispatched EXCEPTION;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

      /* Bug 4891916-Added the following local variables for the call to label printing */
      l_print_label   NUMBER := NVL(FND_PROFILE.VALUE('WMS_LABEL_FOR_CYCLE_COUNT'),2);
      l_business_flow_code NUMBER := 8;
      l_label_status VARCHAR2 ( 300 ) := NULL;
      l_return_status  VARCHAR2(1)  := fnd_api.g_ret_sts_success;
      l_msg_count      NUMBER;
      l_msg_data       VARCHAR2(240);
      /* End of fix for Bug 4891916 */

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***Calling process_entry with the following parameters***'
                     );
         print_debug (    'p_cycle_count_header_id: ===> '
                       || p_cycle_count_header_id
                     );
         print_debug ( 'p_organization_id: =========> ' || p_organization_id );
         print_debug ( 'p_subinventory: ============> ' || p_subinventory );
         print_debug ( 'p_locator_id: ==============> ' || p_locator_id );
         print_debug ( 'p_parent_lpn_id: ===========> ' || p_parent_lpn_id );
         print_debug ( 'p_inventory_item_id: =======> ' || p_inventory_item_id );
         print_debug ( 'p_revision: ================> ' || p_revision );
         print_debug ( 'p_lot_number: ==============> ' || p_lot_number );
         print_debug ( 'p_from_serial_number: ======> '
                       || p_from_serial_number
                     );
         print_debug ( 'p_to_serial_number: ========> ' || p_to_serial_number );
         print_debug ( 'p_count_quantity: ==========> ' || p_count_quantity );
         print_debug ( 'p_count_uom: ===============> ' || p_count_uom );
         print_debug (    'p_unscheduled_count_entry: => '
                       || p_unscheduled_count_entry
                     );
         print_debug ( 'p_user_id: =================> ' || p_user_id );
         print_debug ( 'p_cost_group_id: ===========> ' || p_cost_group_id );
         print_debug ( 'p_secondary_uom: ===========> ' || p_secondary_uom  );   -- INVCONV, NSRIVAST
         print_debug ( 'p_secondary_qty: ===========> ' || p_secondary_qty  );   -- INVCONV, NSRIVAST


      END IF;

      -- Initialize the message stack
      FND_MSG_PUB.initialize;
      -- Set the global variables
      g_count_quantity := p_count_quantity;
      g_count_uom := p_count_uom;
      g_user_id   := p_user_id;
      g_count_secondary_quantity  :=  p_secondary_qty ;   -- INVCONV, NSRIVAST
      g_count_secondary_uom       :=  p_secondary_uom ;   -- INVCONV, NSRIVAST
      -- Get the profile values
      get_profiles ( );
      -- Get the employee ID information
      get_employee ( p_organization_id => p_organization_id );

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Employee ID: ' || g_employee_id );
      END IF;

      BEGIN
         SELECT MIN ( cycle_count_entry_id )
         INTO   l_dispatched_task
         FROM   mtl_cycle_count_entries
         WHERE  cycle_count_header_id = p_cycle_count_header_id
         AND    organization_id = p_organization_id
         AND    subinventory = p_subinventory
         AND    NVL ( locator_id, -99999 ) = NVL ( p_locator_id, -99999 )
         AND    inventory_item_id = p_inventory_item_id
         AND    NVL ( revision, '@@@@@' ) = NVL ( p_revision, '@@@@@' )
         AND    entry_status_code IN ( 1, 3 );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_dispatched_task := -99999;
      END;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Task Temp ID: ' || l_dispatched_task );
      END IF;

      SELECT COUNT ( * )
      INTO   l_dispatched_count
      FROM   wms_dispatched_tasks
      WHERE  task_type = 3
      AND    organization_id = p_organization_id
      AND    transaction_temp_id = l_dispatched_task
      AND    person_id <> NVL ( g_employee_id, -999 );

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Dispatched Count: ' || l_dispatched_count );
      END IF;

      -- Cycle Counting task has already been dispatched
      IF ( l_dispatched_count <> 0 ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug (    'The cycle count entry has already been dispatched as a '
                          || 'task to another user'
                        );
         END IF;

         RAISE e_Task_Dispatched;
      END IF;

      -- Check if the cycle count item is a serial controlled item
      -- This is for single serial count option only
      IF (      ( p_from_serial_number IS NOT NULL )
           AND ( p_to_serial_number IS NOT NULL )
         ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Single Serial controlled item' );
         END IF;

         -- Call this API to parse the serial numbers into prefixes and numbers
         IF ( NOT MTL_Serial_Check.inv_serial_info ( p_from_serial_number => p_from_serial_number,
                                                     p_to_serial_number  => p_to_serial_number,
                                                     x_prefix            => l_prefix,
                                                     x_quantity          => l_quantity,
                                                     x_from_number       => l_from_number,
                                                     x_to_number         => l_to_number,
                                                     x_errorcode         => l_errorcode
                                                   )
            ) THEN
            FND_MESSAGE.SET_NAME ( 'WMS', 'WMS_CONT_INVALID_SER' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Check that in the case of a range of serial numbers, that the
         -- inputted p_count_quantity equals the amount of items in the serial range.
         IF (      ( p_count_quantity <> l_quantity )
              AND ( p_count_quantity <> 0 )
            ) THEN
            FND_MESSAGE.SET_NAME ( 'WMS', 'WMS_CONT_INVALID_X_QTY' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Get the serial number length.
         -- Note that the from and to serial numbers must be of the same length.
         l_length    := LENGTH ( p_from_serial_number );
         -- Initialize the current pointer variables
         l_current_serial := p_from_serial_number;
         l_current_number := l_from_number;

         LOOP
            -- For each serial number check if a cycle count entry for it already
            -- exists or not
            OPEN cc_entry_cursor;
            FETCH cc_entry_cursor INTO g_cc_entry;

            IF ( cc_entry_cursor%FOUND ) THEN
               -- Entry already exists so update the row
               pre_update ( );
               update_row ( );
            ELSE
               -- Get the serial and container discrepancy options for the cycle count
               SELECT NVL ( serial_discrepancy_option, 2 ),
                      NVL ( container_discrepancy_option, 2 )
               INTO   l_serial_discrepancy,
                      l_container_discrepancy
               FROM   mtl_cycle_count_headers
               WHERE  cycle_count_header_id = p_cycle_count_header_id
               AND    organization_id = p_organization_id;

               -- Check to see if the serial entry exists but is in
               -- a discrepant location, i.e. different sub/loc
               -- Bug# 2708133
               -- Use cc_discrepant_serial_cursor instead which will also
               -- allow for rev, lot, and LPN discrepancies for serials
               OPEN cc_discrepant_serial_cursor;
               FETCH cc_discrepant_serial_cursor INTO g_cc_entry;

               -- Allow discrepancies if serial discrepancy is allowed
               -- Bug# 2708133
               -- We only care if serial discrepancies are allowed now
               IF (     cc_discrepant_serial_cursor%FOUND
                    AND l_serial_discrepancy = 1
                  ) THEN
                  -- Discrepant serial entry exists so process it
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Discrepant single serial entry exists' );
                  END IF;

                  -- Update the sub and loc information
                  -- Bug# 2708133
                  -- Also update the rev, lot, and LPN
                  g_cc_entry.subinventory := p_subinventory;
                  g_cc_entry.locator_id := p_locator_id;
                  g_cc_entry.revision := p_revision;
                  g_cc_entry.lot_number := p_lot_number;
                  g_cc_entry.parent_lpn_id := p_parent_lpn_id;
                  pre_update ( );
                  update_row ( );
               ELSE
                  -- Entry does not exist at all
                  IF ( p_unscheduled_count_entry = 1 ) THEN
                     -- Unscheduled entries are allowed so insert the record
                     IF ( l_debug = 1 ) THEN
                        print_debug ( 'Unscheduled single serial entry to be inserted'
                                    );
                     END IF;

                     -- Call this procedure to calculate and update the next
                     -- value for the count list sequence
                     --print_debug('Calling update_count_list_sequence');
                     -- Bug# 2386128
                     -- Dont call this anymore.  Similar to Bug# 1803246 for
                     -- the desktop forms, when doing an unscheduled cycle
                     -- count, we will use the cycle count entry ID as the
                     -- value for the count list sequence
                     /*update_count_list_sequence
                       (p_organization_id        => p_organization_id,
                        p_cycle_count_header_id  => p_cycle_count_header_id,
                        x_count_list_sequence    => l_count_list_sequence);*/

                     -- Get the cost group ID for this entry
                     get_cost_group_id ( p_organization_id   => p_organization_id,
                                         p_subinventory      => p_subinventory,
                                         p_locator_id        => p_locator_id,
                                         p_parent_lpn_id     => p_parent_lpn_id,
                                         p_inventory_item_id => p_inventory_item_id,
                                         p_revision          => p_revision,
                                         p_lot_number        => p_lot_number,
                                         p_serial_number     => l_current_serial,
                                         x_out               => l_cost_group_id
                                       );

                          -- Bug# 2607187
                          -- Do not get the default cost group ID.  If the item is
                          -- new and does not exist in onhand, pass a NULL value
                          -- for the cost group ID.  The transaction manager will
                     -- call the cost group rules engine for that if the
                     -- cost group ID passed into MMTT is null.
                     IF ( l_cost_group_id = -999 ) THEN
                        l_cost_group_id := NULL;
                     END IF;

                     -- Get the default cost group ID based on the given org
                     -- and sub if cost group ID was not retrieved successfully
                     /*IF (l_cost_group_id = -999) THEN
                        get_default_cost_group_id
                          (p_organization_id        =>  p_organization_id,
                      p_subinventory           =>  p_subinventory,
                      x_out                    =>  l_cost_group_id);
                     END IF;
                     -- Default the cost group ID to 1 if nothing can be found
                     IF (l_cost_group_id = -999) THEN
                        l_cost_group_id := 1;
                     END IF;*/

                     -- First prepare the entry record
                     g_cc_entry.cycle_count_entry_id := NULL;
                     g_cc_entry.cycle_count_header_id :=
                                                       p_cycle_count_header_id;
                     g_cc_entry.organization_id := p_organization_id;
                     g_cc_entry.subinventory := p_subinventory;
                     g_cc_entry.locator_id := p_locator_id;
                     g_cc_entry.inventory_item_id := p_inventory_item_id;
                     g_cc_entry.revision := p_revision;
                     g_cc_entry.lot_number := p_lot_number;
                     g_cc_entry.serial_number := l_current_serial;
                     g_cc_entry.parent_lpn_id := p_parent_lpn_id;
                     g_cc_entry.cost_group_id := l_cost_group_id;
                     g_cc_entry.entry_status_code := 1;
                     g_cc_entry.last_update_date := SYSDATE;
                     g_cc_entry.last_updated_by := p_user_id;
                     g_cc_entry.creation_date := SYSDATE;
                     g_cc_entry.created_by := p_user_id;
                     g_cc_entry.last_update_login := g_login_id;
                     g_cc_entry.count_list_sequence := NULL;
                     g_cc_entry.count_type_code := 2;
                     g_cc_entry.number_of_counts := 0;
                     -- Now insert the record
                     pre_insert ( );
                     insert_row ( );
                  ELSE
                     -- Unscheduled entries are not allowed
                     IF ( l_debug = 1 ) THEN
                        print_debug ( 'Unscheduled entries are not allowed' );
                     END IF;
                  --FND_MESSAGE.SET_NAME('INV', 'INV_NO_UNSCHED_COUNTS');
                  --FND_MSG_PUB.ADD;
                  --RAISE FND_API.G_EXC_ERROR;
                  END IF;
               END IF;

               CLOSE cc_discrepant_serial_cursor;
            END IF;

            CLOSE cc_entry_cursor;
            EXIT WHEN l_current_serial = p_to_serial_number;
            -- Increment the current serial number
            l_current_number := l_current_number + 1;
            l_padded_length := l_length - LENGTH ( l_current_number );
            l_current_serial :=
                        RPAD ( l_prefix, l_padded_length, '0' )
                     || l_current_number;
         END LOOP;
      -- This is for multiple serial count option
      ELSIF ( p_count_quantity IS NULL ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Multiple serial controlled item' );
         END IF;

         -- Set a savepoint
         SAVEPOINT save_serial_detail;
         -- For the inputted entries, see if a multiple serial
         -- cycle count entry for it exists
         OPEN cc_multiple_serial_cursor;
         FETCH cc_multiple_serial_cursor INTO g_cc_entry;

         IF ( cc_multiple_serial_cursor%FOUND ) THEN
            -- The entry exists so process all of the multiple
            -- serial cycle count entries associated with it
            ok_proc ( );
            pre_update ( );
            update_row ( );
         ELSE
            -- Get the serial and container discrepancy options for the cycle count
            SELECT NVL ( serial_discrepancy_option, 2 ),
                   NVL ( container_discrepancy_option, 2 )
            INTO   l_serial_discrepancy,
                   l_container_discrepancy
            FROM   mtl_cycle_count_headers
            WHERE  cycle_count_header_id = p_cycle_count_header_id
            AND    organization_id = p_organization_id;

            -- Check to see if the multiple serial entry exists but
            -- is in a discrepant location, i.e. different sub/loc
            OPEN cc_discrepant_multiple_cursor;
            FETCH cc_discrepant_multiple_cursor INTO g_cc_entry;

            -- Allow discrepancies if container discrepancy is allowed and
            -- there is an LPN, or serial discrepancy is allowed and there
            -- is no LPN
            IF (     cc_discrepant_multiple_cursor%FOUND
                 AND (     (     l_container_discrepancy = 1
                             AND p_parent_lpn_id IS NOT NULL
                           )
                       OR (     l_serial_discrepancy = 1
                            AND p_parent_lpn_id IS NULL
                          )
                     )
               ) THEN
               -- Discrepant multiple serial entry exists so process it
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Discrepant multiple serial entry exists' );
               END IF;

               -- Update the sub and loc information
               g_cc_entry.subinventory := p_subinventory;
               g_cc_entry.locator_id := p_locator_id;
               ok_proc ( );
               pre_update ( );
               update_row ( );
            ELSE
               -- Unscheduled multiple count entried are
               -- not being supported right now
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Unscheduled multiple serial count' );
               END IF;
            END IF;

            CLOSE cc_discrepant_multiple_cursor;
         END IF;

         CLOSE cc_multiple_serial_cursor;
      ELSE -- Item is not serial controlled
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Non serial controlled item' );
         END IF;

         OPEN cc_entry_cursor;
         FETCH cc_entry_cursor INTO g_cc_entry;

         IF ( cc_entry_cursor%FOUND ) THEN
            pre_update ( );
            update_row ( );
         ELSE
            -- Get the container discrepancy option for the cycle count
            SELECT NVL ( container_discrepancy_option, 2 )
            INTO   l_container_discrepancy
            FROM   mtl_cycle_count_headers
            WHERE  cycle_count_header_id = p_cycle_count_header_id
            AND    organization_id = p_organization_id;

            -- Check to see if the entry exists but
            -- is in a discrepant location, i.e. different sub/loc
            OPEN cc_discrepant_cursor;
            FETCH cc_discrepant_cursor INTO g_cc_entry;

            -- Allow discrepancies if container discrepancy is allowed and
            -- there is an LPN
            IF (     cc_discrepant_cursor%FOUND
                 AND (     l_container_discrepancy = 1
                       AND p_parent_lpn_id IS NOT NULL
                     )
               ) THEN
               -- Discrepant containerized entry exists so process it
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Discrepant non-serial entry exists' );
               END IF;

               -- Update the sub and loc information
               g_cc_entry.subinventory := p_subinventory;
               g_cc_entry.locator_id := p_locator_id;
               pre_update ( );
               update_row ( );
            ELSE
               -- Entry does not exist at all
               IF ( p_unscheduled_count_entry = 1 ) THEN
                  -- Unscheduled entries are allowed so insert the record
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Unscheduled non-serial entry to be inserted'
                                 );
                  END IF;

                  -- Call this procedure to calculate and update the next
                  -- value for the count list sequence
                  --print_debug('Calling update_count_list_sequence');
                  -- Bug# 2386128
                  -- Don't call this anymore.  Similar to Bug# 1803246 for
                  -- the desktop forms, when doing an unscheduled cycle
                  -- count, we will use the cycle count entry ID as the
                  -- value for the count list sequence
                  /*update_count_list_sequence
                    (p_organization_id        => p_organization_id,
                p_cycle_count_header_id  => p_cycle_count_header_id,
                x_count_list_sequence    => l_count_list_sequence);*/

                  -- Get the cost group ID for this entry
                  get_cost_group_id ( p_organization_id   => p_organization_id,
                                      p_subinventory      => p_subinventory,
                                      p_locator_id        => p_locator_id,
                                      p_parent_lpn_id     => p_parent_lpn_id,
                                      p_inventory_item_id => p_inventory_item_id,
                                      p_revision          => p_revision,
                                      p_lot_number        => p_lot_number,
                                      p_serial_number     => NULL,
                                      x_out               => l_cost_group_id
                                    );

                       -- Bug# 2607187
                       -- Do not get the default cost group ID.  If the item is
                       -- new and does not exist in onhand, pass a NULL value
                  -- for the cost group ID.  The transaction manager will
                  -- call the cost group rules engine for that if the
                  -- cost group ID passed into MMTT is null.
                  IF ( l_cost_group_id = -999 ) THEN
                     l_cost_group_id := NULL;
                  END IF;

                  -- Get the default cost group ID based on the given org
                  -- and sub if cost group ID was not retrieved successfully
                  /*IF (l_cost_group_id = -999) THEN
                get_default_cost_group_id
                  (p_organization_id        =>  p_organization_id,
                   p_subinventory           =>  p_subinventory,
                   x_out                    =>  l_cost_group_id);
                  END IF;
                  -- Default the cost group ID to 1 if nothing can be found
                  IF (l_cost_group_id = -999) THEN
                l_cost_group_id := 1;
                  END IF;*/

                  -- First prepare the entry record
                  g_cc_entry.cycle_count_entry_id := NULL;
                  g_cc_entry.cycle_count_header_id := p_cycle_count_header_id;
                  g_cc_entry.organization_id := p_organization_id;
                  g_cc_entry.subinventory := p_subinventory;
                  g_cc_entry.locator_id := p_locator_id;
                  g_cc_entry.inventory_item_id := p_inventory_item_id;
                  g_cc_entry.revision := p_revision;
                  g_cc_entry.lot_number := p_lot_number;
                  g_cc_entry.serial_number := NULL;
                  g_cc_entry.parent_lpn_id := p_parent_lpn_id;
                  g_cc_entry.cost_group_id := l_cost_group_id;
                  g_cc_entry.entry_status_code := 1;
                  g_cc_entry.last_update_date := SYSDATE;
                  g_cc_entry.last_updated_by := p_user_id;
                  g_cc_entry.creation_date := SYSDATE;
                  g_cc_entry.created_by := p_user_id;
                  g_cc_entry.last_update_login := g_login_id;
                  g_cc_entry.count_list_sequence := NULL;
                  g_cc_entry.count_type_code := 2;
                  g_cc_entry.number_of_counts := 0;
                  -- Now insert the record
                  pre_insert ( );
                  insert_row ( );
               ELSE
                  -- Unscheduled entries are not allowed
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Unscheduled entries are not allowed' );
                  END IF;
               --FND_MESSAGE.SET_NAME('INV', 'INV_NO_UNSCHED_COUNTS');
               --FND_MSG_PUB.ADD;
               --RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;

            CLOSE cc_discrepant_cursor;
         END IF;

         CLOSE cc_entry_cursor;
      END IF;

      /*  Bug 4891916 -Calling the label printing api if the profile value corresponds to
                    At Entry(1) or At Entry and Approval(3)  */

        IF (l_print_label IN (1,3) ) THEN

           IF ( l_debug = 1 ) THEN
            print_debug ( 'Values of parameters passed to label printing API:' );
            print_debug ( 'Values of l_business_flow_code'|| l_business_flow_code );
            print_debug ( 'Values of g_cc_entry.cycle_count_entry_id'|| g_cc_entry.cycle_count_entry_id );
           END IF;
           /* Calling with the value of p_transaction_identifier as 4.
              In the label printing code, this value will indicate
              that the call is at the time of performing a cycle count entry
              The value of p_transaction_identifier 5 in the label printing api
              indicates that the call is at the time of approving counts.*/

          inv_label.print_label_wrap
            ( x_return_status          =>  l_return_status        ,
              x_msg_count              =>  l_msg_count            ,
              x_msg_data               =>  l_msg_data             ,
              x_label_status           =>  l_label_status         ,
              p_business_flow_code     =>  l_business_flow_code   ,
              p_transaction_id         =>  g_cc_entry.cycle_count_entry_id ,
              p_transaction_identifier =>  4);

          IF ( l_debug = 1 ) THEN
             print_debug ( 'Values of l_return_status:'|| l_return_status );
             print_debug ( 'Values of l_msg_count:'|| l_msg_count );
             print_debug ( 'Values of l_label_status'|| l_label_status );
          END IF;

          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
           IF (l_debug = 1) THEN
             print_debug('**Label Printing returned error:' || l_return_status);
           END IF;
         END IF;

       END IF ; --End of check for l_print_label value

   /* End of fix for Bug 4891916 */


      IF ( l_debug = 1 ) THEN
         print_debug ( '***End of process_entry***' );
      END IF;
   EXCEPTION
      WHEN e_Task_Dispatched THEN
         FND_MESSAGE.SET_NAME ( 'WMS', 'WMS_TD_CYC_TASK_ERROR' );
         FND_MSG_PUB.ADD;

         IF ( l_debug = 1 ) THEN
            print_debug ( '***End of process_entry***' );
         END IF;
   END process_entry;

    /* start of fix for 4539926 */
   PROCEDURE delete_wdt(
      p_cycle_count_header_id    IN    NUMBER            ,
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
      p_cost_group_id            IN    NUMBER            )

      IS
         l_cycle_count_entry_id NUMBER;
         l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

         CURSOR cc_entry_cursor
         IS
            SELECT  cycle_count_entry_id
            FROM   mtl_cycle_count_entries mcce, wms_dispatched_tasks wdt
            WHERE  mcce.cycle_count_header_id = p_cycle_count_header_id
            AND    mcce.cycle_count_entry_id = wdt.transaction_temp_id
            AND    mcce.organization_id = p_organization_id
            AND    mcce.subinventory = p_subinventory
            AND    mcce.locator_id = p_locator_id
            AND    NVL (mcce.parent_lpn_id, -99999) = NVL ( p_parent_lpn_id, -99999)
            AND    mcce.inventory_item_id = NVL (p_inventory_item_id, mcce.inventory_item_id)
            AND    NVL (mcce.revision, '@@@@@' ) = NVL (p_revision , '@@@@@' )
            AND    NVL (mcce.lot_number, '@@@@@' ) = NVL ( p_lot_number, '@@@@@' )
            AND    NVL (mcce.serial_number, '@@@@@' ) = NVL ( p_from_serial_number, '@@@@@' )
            AND    NVL (mcce.serial_number, '@@@@@' ) = NVL ( p_to_serial_number, '@@@@@' )
            AND    mcce.entry_status_code IN (2, 4, 5 );

     BEGIN
         IF ( l_debug = 1 ) THEN
            print_debug ( '***In delete_wdt ***');
            print_debug ( 'p_cycle_count_header_id: ===> '
                          || p_cycle_count_header_id);
            print_debug ( 'p_organization_id: =========> ' || p_organization_id );
            print_debug ( 'p_subinventory: ============> ' || p_subinventory );
            print_debug ( 'p_locator_id: ==============> ' || p_locator_id );
            print_debug ( 'p_parent_lpn_id: ===========> ' || p_parent_lpn_id );
            print_debug ( 'p_inventory_item_id: =======> ' || p_inventory_item_id );
            print_debug ( 'p_revision: ================> ' || p_revision );
            print_debug ( 'p_lot_number: ==============> ' || p_lot_number );
            print_debug ( 'p_from_serial_number: ======> '
                          || p_from_serial_number);
            print_debug ( 'p_to_serial_number: ========> ' || p_to_serial_number );
            print_debug ( 'p_count_quantity: ==========> ' || p_count_quantity );
            print_debug ( 'p_count_uom: ===============> ' || p_count_uom );
            print_debug ( 'p_unscheduled_count_entry: => '
                          || p_unscheduled_count_entry);
            print_debug ( 'p_user_id: =================> ' || p_user_id );
            print_debug ( 'p_cost_group_id: ===========> ' || p_cost_group_id );
         END IF;

         -- Initialize the message stack
         FND_MSG_PUB.initialize;

         -- To fetch the cycle count entry ids which are in status 2,4,5.
         -- for these entries if a record in wms_dispatched_tasks exists,
         -- it has to be deleted

         OPEN cc_entry_cursor;
           LOOP

            FETCH cc_entry_cursor INTO l_cycle_count_entry_id;
             IF ( cc_entry_cursor%FOUND ) THEN
                IF ( l_debug = 1 ) THEN
                   print_debug ( 'Approval Pending/ Rejected/ Completed cycle count entries found' );
                   print_debug( 'Cycle count Entry Id: ' || l_cycle_count_entry_id);
                END IF;
                BEGIN
                   DELETE FROM wms_dispatched_tasks wdt
                   WHERE wdt.transaction_temp_id = l_cycle_count_entry_id;
                   IF ( l_debug = 1 ) THEN
                      print_debug('** Deleted wms_dispatched_tasks record with transaction_temp_id : ' || l_cycle_count_entry_id);
                   END IF;
                EXCEPTION
                   WHEN OTHERS THEN
                   IF ( l_debug = 1 ) THEN
                      print_debug('Deleting wms_dispatched_tasks record failed');
                   END IF;
                END;
             ELSE
                IF ( l_debug = 1 ) THEN
                   print_debug ( 'No Approval Pending/ Rejected/ Completed cycle count entries found');
                END IF;
                EXIT;   -- Bug No 5068178, moved this exit outside the if condition.
             END IF;
           END LOOP;
         CLOSE cc_entry_cursor;
         IF ( l_debug = 1 ) THEN
              print_debug ( 'Exiting delete_wdt');
         END IF;

   END delete_wdt;

   /* end of fix for 4539926 */






   PROCEDURE insert_row
   IS
      l_return_status VARCHAR2 ( 300 );
      l_msg_count NUMBER;
      l_msg_data VARCHAR2 ( 300 );
      l_lpn_list WMS_Container_PUB.LPN_Table_Type;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***insert_row***' );
      END IF;

      -- Get the outermost LPN ID if this entry contains an LPN
      IF ( g_cc_entry.parent_lpn_id IS NOT NULL ) THEN
         --Bug2935754 starts
         /*
         WMS_Container_PUB.Get_Outermost_LPN ( p_api_version       => 1.0,
                                               x_return_status     => l_return_status,
                                               x_msg_count         => l_msg_count,
                                               x_msg_data          => l_msg_data,
                                               p_lpn_id            => g_cc_entry.parent_lpn_id,
                                               x_lpn_list          => l_lpn_list
                                             );
         g_cc_entry.outermost_lpn_id := l_lpn_list ( 1 ).lpn_id;
         */
       BEGIN
           SELECT outermost_lpn_id
           INTO   g_cc_entry.outermost_lpn_id
           FROM   WMS_LICENSE_PLATE_NUMBERS
           WHERE  lpn_id = g_cc_entry.parent_lpn_id;
       EXCEPTION
           WHEN OTHERS THEN
             IF(l_debug = 1) THEN
               print_debug('Unable to get the Outermost LPN ID for: ' || g_cc_entry.parent_lpn_id);
             END IF;
             RAISE  FND_API.G_EXC_ERROR;
       END;
          --Bug2935754 ends
      ELSE
         g_cc_entry.outermost_lpn_id := NULL;
      END IF;

--bug fix 7429096 kbanddyo   added few columns in the insert statement related to sec qty .
      INSERT INTO mtl_cycle_count_entries
                  ( cycle_count_entry_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    count_list_sequence,
                    count_date_first,
                    count_date_current,
-- Commented the Line Below for Bug 8333418
--                    count_date_prior,
                    count_date_dummy,
                    counted_by_employee_id_first,
                    counted_by_employee_id_current,
-- Commented the Line Below for Bug 8333418
--                    counted_by_employee_id_prior,
                    counted_by_employee_id_dummy,
                    count_uom_first,
                    count_uom_current,
-- Commented the Line Below for Bug 8333418
--                    count_uom_prior,
                    count_quantity_first,
                    count_quantity_current,
-- Commented the Line Below for Bug 8333418
--                    count_quantity_prior,
                    inventory_item_id,
                    subinventory,
                    entry_status_code,
                    count_due_date,
                    organization_id,
                    cycle_count_header_id,
                    number_of_counts,
                    locator_id,
                    adjustment_quantity,
                    adjustment_date,
                    adjustment_amount,
                    item_unit_cost,
                    inventory_adjustment_account,
                    approval_date,
                    approver_employee_id,
                    revision,
                    lot_number,
                    lot_control,
                    system_quantity_first,
                    system_quantity_current,
-- Commented the Line Below for Bug 8333418
--                    system_quantity_prior,
                    reference_first,
                    reference_current,
-- Commented the Line Below for Bug 8333418
--                    reference_prior,
                    primary_uom_quantity_first,
                    primary_uom_quantity_current,
-- Commented the Line Below for Bug 8333418
--                    primary_uom_quantity_prior,
                    count_type_code,
                    transaction_reason_id,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    approval_type,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    serial_number,
                    serial_detail,
                    approval_condition,
                    neg_adjustment_quantity,
                    neg_adjustment_amount,
                    export_flag,
                    task_priority,
                    standard_operation_id,
                    parent_lpn_id,
                    outermost_lpn_id,
                    cost_group_id
                    -- INVCONV, NSRIVAST
                    ,secondary_uom_quantity_first
                    ,secondary_uom_quantity_current
                    ,secondary_uom_quantity_prior
                    ,count_secondary_uom_first
                    ,count_secondary_uom_current
                    ,count_secondary_uom_prior
                    -- INVCONV, NSRIVAST
                    ,SECONDARY_ADJUSTMENT_QUANTITY     --bug fix 7429096
                    ,SECONDARY_SYSTEM_QTY_FIRST             --bug fix 7429096
                    ,SECONDARY_SYSTEM_QTY_CURRENT      --bug fix 7429096
                  )
           VALUES ( g_cc_entry.cycle_count_entry_id,
                    g_cc_entry.last_update_date,
                    g_cc_entry.last_updated_by,
                    g_cc_entry.creation_date,
                    g_cc_entry.created_by,
                    g_cc_entry.last_update_login,
                    g_cc_entry.count_list_sequence,
                    g_cc_entry.count_date_first,
                    g_cc_entry.count_date_current,
-- Commented the Line Below for Bug 8333418
--                    g_cc_entry.count_date_prior,
                    g_cc_entry.count_date_dummy,
                    g_cc_entry.counted_by_employee_id_first,
                    g_cc_entry.counted_by_employee_id_current,
-- Commented the Line Below for Bug 8333418
--                    g_cc_entry.counted_by_employee_id_prior,
                    g_cc_entry.counted_by_employee_id_dummy,
                    g_cc_entry.count_uom_first,
                    g_cc_entry.count_uom_current,
-- Commented the Line Below for Bug 8333418
--                    g_cc_entry.count_uom_prior,
                    g_cc_entry.count_quantity_first,
                    g_cc_entry.count_quantity_current,
-- Commented the Line Below for Bug 8333418
--                    g_cc_entry.count_quantity_prior,
                    g_cc_entry.inventory_item_id,
                    g_cc_entry.subinventory,
                    g_cc_entry.entry_status_code,
                    g_cc_entry.count_due_date,
                    g_cc_entry.organization_id,
                    g_cc_entry.cycle_count_header_id,
                    g_cc_entry.number_of_counts,
                    g_cc_entry.locator_id,
                    g_cc_entry.adjustment_quantity,
                    g_cc_entry.adjustment_date,
                    g_cc_entry.adjustment_amount,
                    g_cc_entry.item_unit_cost,
                    g_cc_entry.inventory_adjustment_account,
                    g_cc_entry.approval_date,
                    g_cc_entry.approver_employee_id,
                    g_cc_entry.revision,
                    g_cc_entry.lot_number,
                    g_cc_entry.lot_control,
                    g_cc_entry.system_quantity_first,
                    g_cc_entry.system_quantity_current,
-- Commented the Line Below for Bug 8333418
--                    g_cc_entry.system_quantity_prior,
                    g_cc_entry.reference_first,
                    g_cc_entry.reference_current,
-- Commented the Line Below for Bug 8333418
--                    g_cc_entry.reference_prior,
                    g_cc_entry.primary_uom_quantity_first,
                    g_cc_entry.primary_uom_quantity_current,
-- Commented the Line Below for Bug 8333418
--                    g_cc_entry.primary_uom_quantity_prior,
                    g_cc_entry.count_type_code,
                    g_cc_entry.transaction_reason_id,
                    g_cc_entry.request_id,
                    g_cc_entry.program_application_id,
                    g_cc_entry.program_id,
                    g_cc_entry.program_update_date,
                    g_cc_entry.approval_type,
                    g_cc_entry.attribute_category,
                    g_cc_entry.attribute1,
                    g_cc_entry.attribute2,
                    g_cc_entry.attribute3,
                    g_cc_entry.attribute4,
                    g_cc_entry.attribute5,
                    g_cc_entry.attribute6,
                    g_cc_entry.attribute7,
                    g_cc_entry.attribute8,
                    g_cc_entry.attribute9,
                    g_cc_entry.attribute10,
                    g_cc_entry.attribute11,
                    g_cc_entry.attribute12,
                    g_cc_entry.attribute13,
                    g_cc_entry.attribute14,
                    g_cc_entry.attribute15,
                    LTRIM ( RTRIM ( g_cc_entry.serial_number ) ),
                                                                /* BUG2842145*/
                    g_cc_entry.serial_detail,
                    g_cc_entry.approval_condition,
                    g_cc_entry.neg_adjustment_quantity,
                    g_cc_entry.neg_adjustment_amount,
                    g_cc_entry.export_flag,
                    g_cc_entry.task_priority,
                    g_cc_entry.standard_operation_id,
                    g_cc_entry.parent_lpn_id,
                    g_cc_entry.outermost_lpn_id,
                    g_cc_entry.cost_group_id
                    -- INVCONV, NSRIVAST
                    ,g_cc_entry.secondary_uom_quantity_first
                    ,g_cc_entry.secondary_uom_quantity_current
                    ,g_cc_entry.secondary_uom_quantity_prior
                    ,g_cc_entry.count_secondary_uom_first
                    ,g_cc_entry.count_secondary_uom_current
                    ,g_cc_entry.count_secondary_uom_prior
                    -- INVCONV, NSRIVAST
                    ,g_cc_entry.SECONDARY_ADJUSTMENT_QUANTITY  --bug fix 7429096
                    ,g_cc_entry.SECONDARY_SYSTEM_QTY_FIRST          --bug fix 7429096
                    ,g_cc_entry.SECONDARY_SYSTEM_QTY_CURRENT   --bug fix 7429096
                  );

      IF ( SQL%NOTFOUND ) THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END insert_row;

   PROCEDURE update_row
   IS
      l_return_status VARCHAR2 ( 300 );
      l_msg_count NUMBER;
      l_msg_data VARCHAR2 ( 300 );
      l_lpn_list WMS_Container_PUB.LPN_Table_Type;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***update_row***' );
      END IF;

      -- Set the WHO column information
      g_cc_entry.last_update_date := SYSDATE;
      g_cc_entry.last_updated_by := g_user_id;
      g_cc_entry.last_update_login := g_login_id;

      -- Get the outermost LPN ID if this entry contains an LPN
      IF ( g_cc_entry.parent_lpn_id IS NOT NULL ) THEN
         --Bug2935754
         /*
         WMS_Container_PUB.Get_Outermost_LPN ( p_api_version       => 1.0,
                                               x_return_status     => l_return_status,
                                               x_msg_count         => l_msg_count,
                                               x_msg_data          => l_msg_data,
                                               p_lpn_id            => g_cc_entry.parent_lpn_id,
                                               x_lpn_list          => l_lpn_list
                                             );
         g_cc_entry.outermost_lpn_id := l_lpn_list ( 1 ).lpn_id;*/
       BEGIN
           SELECT outermost_lpn_id
           INTO   g_cc_entry.outermost_lpn_id
           FROM   WMS_LICENSE_PLATE_NUMBERS
           WHERE  lpn_id = g_cc_entry.parent_lpn_id;
       EXCEPTION
           WHEN OTHERS THEN
             IF(l_debug = 1) THEN
               print_debug('Unable to get the Outermost LPN ID for: ' || g_cc_entry.parent_lpn_id);
             END IF;
             RAISE  FND_API.G_EXC_ERROR;
       END;
          --Bug2935754 ends
      ELSE
         g_cc_entry.outermost_lpn_id := NULL;
      END IF;

      UPDATE mtl_cycle_count_entries
      SET last_update_date = g_cc_entry.last_update_date,
          last_updated_by = g_cc_entry.last_updated_by,
          last_update_login = g_cc_entry.last_update_login,
          count_list_sequence = g_cc_entry.count_list_sequence,
          count_date_first = g_cc_entry.count_date_first,
          count_date_current = g_cc_entry.count_date_current,
          count_date_prior = g_cc_entry.count_date_prior,
          count_date_dummy = g_cc_entry.count_date_dummy,
          counted_by_employee_id_first =
                                       g_cc_entry.counted_by_employee_id_first,
          counted_by_employee_id_current =
                                     g_cc_entry.counted_by_employee_id_current,
          counted_by_employee_id_prior =
                                       g_cc_entry.counted_by_employee_id_prior,
          counted_by_employee_id_dummy =
                                       g_cc_entry.counted_by_employee_id_dummy,
          count_uom_first = g_cc_entry.count_uom_first,
          count_uom_current = g_cc_entry.count_uom_current,
          count_uom_prior = g_cc_entry.count_uom_prior,
          count_quantity_first = g_cc_entry.count_quantity_first,
          count_quantity_current = g_cc_entry.count_quantity_current,
          count_quantity_prior = g_cc_entry.count_quantity_prior,
          inventory_item_id = g_cc_entry.inventory_item_id,
          subinventory = g_cc_entry.subinventory,
          entry_status_code = g_cc_entry.entry_status_code,
          count_due_date = g_cc_entry.count_due_date,
          organization_id = g_cc_entry.organization_id,
          cycle_count_header_id = g_cc_entry.cycle_count_header_id,
          number_of_counts = g_cc_entry.number_of_counts,
          locator_id = g_cc_entry.locator_id,
          adjustment_quantity = g_cc_entry.adjustment_quantity,
          adjustment_date = g_cc_entry.adjustment_date,
          adjustment_amount = g_cc_entry.adjustment_amount,
          item_unit_cost = g_cc_entry.item_unit_cost,
          inventory_adjustment_account =
                                       g_cc_entry.inventory_adjustment_account,
          approval_date = g_cc_entry.approval_date,
          approver_employee_id = g_cc_entry.approver_employee_id,
          revision = g_cc_entry.revision,
          lot_number = g_cc_entry.lot_number,
          lot_control = g_cc_entry.lot_control,
          system_quantity_first = g_cc_entry.system_quantity_first,
          system_quantity_current = g_cc_entry.system_quantity_current,
          system_quantity_prior = g_cc_entry.system_quantity_prior,
          reference_first = g_cc_entry.reference_first,
          reference_current = g_cc_entry.reference_current,
          reference_prior = g_cc_entry.reference_prior,
          primary_uom_quantity_first = g_cc_entry.primary_uom_quantity_first,
          primary_uom_quantity_current =
                                       g_cc_entry.primary_uom_quantity_current,
          primary_uom_quantity_prior = g_cc_entry.primary_uom_quantity_prior,
          count_type_code = g_cc_entry.count_type_code,
          transaction_reason_id = g_cc_entry.transaction_reason_id,
          approval_type = g_cc_entry.approval_type,
          attribute_category = g_cc_entry.attribute_category,
          attribute1 = g_cc_entry.attribute1,
          attribute2 = g_cc_entry.attribute2,
          attribute3 = g_cc_entry.attribute3,
          attribute4 = g_cc_entry.attribute4,
          attribute5 = g_cc_entry.attribute5,
          attribute6 = g_cc_entry.attribute6,
          attribute7 = g_cc_entry.attribute7,
          attribute8 = g_cc_entry.attribute8,
          attribute9 = g_cc_entry.attribute9,
          attribute10 = g_cc_entry.attribute10,
          attribute11 = g_cc_entry.attribute11,
          attribute12 = g_cc_entry.attribute12,
          attribute13 = g_cc_entry.attribute13,
          attribute14 = g_cc_entry.attribute14,
          attribute15 = g_cc_entry.attribute15,
          serial_number = g_cc_entry.serial_number,
          serial_detail = g_cc_entry.serial_detail,
          approval_condition = g_cc_entry.approval_condition,
          neg_adjustment_quantity = g_cc_entry.neg_adjustment_quantity,
          neg_adjustment_amount = g_cc_entry.neg_adjustment_amount,
          parent_lpn_id = g_cc_entry.parent_lpn_id,
          outermost_lpn_id = g_cc_entry.outermost_lpn_id,
          cost_group_id = g_cc_entry.cost_group_id
           -- INVCONV, NSRIVAST
          ,secondary_uom_quantity_first    =   g_cc_entry.secondary_uom_quantity_first ,
          secondary_uom_quantity_current  =   g_cc_entry.secondary_uom_quantity_current,
          secondary_uom_quantity_prior    =   g_cc_entry.secondary_uom_quantity_prior ,
          count_secondary_uom_first       =   g_cc_entry.count_secondary_uom_first,
          count_secondary_uom_current     =   g_cc_entry.count_secondary_uom_current,
          count_secondary_uom_prior       =   g_cc_entry.count_secondary_uom_prior,
          -- INVCONV, NSRIVAST
	  -- nsinghi Bug#6052831 START
	  secondary_adjustment_quantity   =   g_cc_entry.secondary_adjustment_quantity,
	  secondary_system_qty_current    =   g_cc_entry.secondary_system_qty_current,
	  secondary_system_qty_first      =   g_cc_entry.secondary_system_qty_first,
	  secondary_system_qty_prior      =   g_cc_entry.secondary_system_qty_prior
	  -- nsinghi Bug#6052831 END
      WHERE  cycle_count_entry_id = g_cc_entry.cycle_count_entry_id;

      IF ( SQL%NOTFOUND ) THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END update_row;

   PROCEDURE current_to_prior
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***current_to_prior***' );
      END IF;

      -- Set all of the prior fields equal to the current fields
      g_cc_entry.count_date_prior := g_cc_entry.count_date_current;
      g_cc_entry.counted_by_employee_id_prior :=
                                     g_cc_entry.counted_by_employee_id_current;
      g_cc_entry.count_uom_prior := g_cc_entry.count_uom_current;
      g_cc_entry.count_quantity_prior := g_cc_entry.count_quantity_current;
      g_cc_entry.system_quantity_prior := g_cc_entry.system_quantity_current;
      g_cc_entry.secondary_system_qty_prior := g_cc_entry.secondary_system_qty_current; -- nsinghi Bug#6052831 Added this line.
      g_cc_entry.reference_prior := g_cc_entry.reference_current;
      g_cc_entry.primary_uom_quantity_prior :=
                                       g_cc_entry.primary_uom_quantity_current;
      -- INVCONV, NSRIVAST
      g_cc_entry.count_secondary_uom_prior     :=   g_cc_entry.count_secondary_uom_current ;
      g_cc_entry.secondary_uom_quantity_prior  :=   g_cc_entry.secondary_uom_quantity_current ;
      -- INVCONV, NSRIVAST
   END current_to_prior;

   PROCEDURE current_to_first
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***current_to_first***' );
      END IF;

      -- Set all of the first fields equal to the current fields
      g_cc_entry.count_date_first := g_cc_entry.count_date_current;
      g_cc_entry.counted_by_employee_id_first :=
                                     g_cc_entry.counted_by_employee_id_current;
      g_cc_entry.count_uom_first := g_cc_entry.count_uom_current;
      g_cc_entry.count_quantity_first := g_cc_entry.count_quantity_current;
      g_cc_entry.system_quantity_first := g_cc_entry.system_quantity_current;
      g_cc_entry.secondary_system_qty_first := g_cc_entry.secondary_system_qty_current; -- nsinghi Bug#6052831 Added this line.
      g_cc_entry.reference_first := g_cc_entry.reference_current;
      g_cc_entry.primary_uom_quantity_first :=
                                       g_cc_entry.primary_uom_quantity_current;
      -- INVCONV, NSRIVAST
      g_cc_entry.count_secondary_uom_first     :=   g_cc_entry.count_secondary_uom_current ;
      g_cc_entry.secondary_uom_quantity_first  :=   g_cc_entry.secondary_uom_quantity_current ;
      -- INVCONV, NSRIVAST
   END current_to_first;

-- nsinghi bug#6052831
   PROCEDURE entry_to_current (
      p_count_date IN DATE,
      p_counted_by_employee_id IN NUMBER,
      p_system_quantity IN NUMBER,
      p_reference IN VARCHAR2,
      p_primary_uom_quantity IN NUMBER,
      p_sec_system_quantity IN NUMBER DEFAULT NULL -- nsinghi Bug#6052831 Added this parameter.
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***entry_to_current***' );
      END IF;

      -- Set all of the current fields equal to the given entries
      g_cc_entry.count_date_current := p_count_date;
      g_cc_entry.counted_by_employee_id_current := p_counted_by_employee_id;
      g_cc_entry.count_uom_current := g_count_uom;
      g_cc_entry.count_quantity_current := g_count_quantity;
      g_cc_entry.system_quantity_current := p_system_quantity;
      g_cc_entry.secondary_system_qty_current := p_sec_system_quantity; -- nsinghi Bug#6052831 Added this line.
      g_cc_entry.reference_current := p_reference;
      g_cc_entry.primary_uom_quantity_current := p_primary_uom_quantity;
      -- INVCONV, NSRIVAST
      g_cc_entry.count_secondary_uom_current     := g_count_secondary_uom ;
      g_cc_entry.secondary_uom_quantity_current  := g_count_secondary_quantity ;
      -- INVCONV, NSRIVAST
   END entry_to_current;

   PROCEDURE zero_count_logic
   IS
      l_primary_uom_quantity NUMBER;
      l_primary_uom VARCHAR2 ( 3 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***zero_count_logic***' );
      END IF;

      -- Set the default values for a zero count entry
      g_cc_entry.system_quantity_current := 0;
      g_cc_entry.number_of_counts := 1;
      g_cc_entry.entry_status_code := 5;
      g_cc_entry.approval_type := 1;
      g_cc_entry.approver_employee_id := g_employee_id;
      g_cc_entry.approval_date := SYSDATE;

      -- Get the item primary uom code
      SELECT primary_uom_code
      INTO   l_primary_uom
      FROM   MTL_SYSTEM_ITEMS
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Convert the count quantity into the item primary uom quantity
      l_primary_uom_quantity :=
         inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                      6,
                                      g_count_quantity,
                                      g_count_uom,
                                      l_primary_uom,
                                      NULL,
                                      NULL
                                    );
      -- Set the entry values to the current fields
      entry_to_current ( p_count_date        => SYSDATE,
                         p_counted_by_employee_id => g_employee_id,
                         p_system_quantity   => 0,
                         p_reference         => NULL,
                         p_primary_uom_quantity => l_primary_uom_quantity,
                         p_sec_system_quantity => 0 -- nsinghi Bug#6052831 Added this line.
                       );
      -- Set the current values to the first fields.
      current_to_first ( );
   END zero_count_logic;

-- Since approval tolerances can be defined at the cycle count header,
-- item, and class level, we need to choose the appropriate one.
-- Similarly, cost tolerances can be defined at the cycle count header
-- and class level.
   PROCEDURE get_tolerances (
      pre_approve_flag IN VARCHAR2,
      x_approval_tolerance_positive OUT NOCOPY NUMBER,
      x_approval_tolerance_negative OUT NOCOPY NUMBER,
      x_cost_tolerance_positive OUT NOCOPY NUMBER,
      x_cost_tolerance_negative OUT NOCOPY NUMBER
   )
   IS
      l_item_app_tol_pos NUMBER;
      l_item_app_tol_neg NUMBER;
      l_class_app_tol_pos NUMBER;
      l_class_app_tol_neg NUMBER;
      l_head_app_tol_pos NUMBER;
      l_head_app_tol_neg NUMBER;
      l_class_cost_tol_pos NUMBER;
      l_class_cost_tol_neg NUMBER;
      l_head_cost_tol_pos NUMBER;
      l_head_cost_tol_neg NUMBER;
      l_inventory_item_id NUMBER;
      l_organization_id NUMBER;
      l_cycle_count_header_id NUMBER;
      l_abc_class_id NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_tolerances***' );
      END IF;

      -- Get the required information from the cycle count entry record
      -- which will serve as the primary keys to get the tolerances from
      -- the various cycle count tables
      l_inventory_item_id := g_cc_entry.inventory_item_id;
      l_organization_id := g_cc_entry.organization_id;
      l_cycle_count_header_id := g_cc_entry.cycle_count_header_id;

      BEGIN
         SELECT abc_class_id
         INTO   l_abc_class_id
         FROM   mtl_cycle_count_items
         WHERE  cycle_count_header_id = l_cycle_count_header_id
         AND    inventory_item_id = l_inventory_item_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_abc_class_id := NULL;
      END;

      -- Get all of the values of the tolerances
      IF ( l_abc_class_id IS NOT NULL ) THEN
         SELECT approval_tolerance_positive,
                approval_tolerance_negative
         INTO   l_item_app_tol_pos,
                l_item_app_tol_neg
         FROM   mtl_cycle_count_items
         WHERE  cycle_count_header_id = l_cycle_count_header_id
         AND    inventory_item_id = l_inventory_item_id;
      ELSE
         l_item_app_tol_pos := NULL;
         l_item_app_tol_neg := NULL;
      END IF;

      IF ( l_abc_class_id IS NOT NULL ) THEN
         SELECT approval_tolerance_positive,
                approval_tolerance_negative,
                cost_tolerance_positive,
                cost_tolerance_negative
         INTO   l_class_app_tol_pos,
                l_class_app_tol_neg,
                l_class_cost_tol_pos,
                l_class_cost_tol_neg
         FROM   mtl_cycle_count_classes
         WHERE  abc_class_id = l_abc_class_id
         AND    cycle_count_header_id = l_cycle_count_header_id;
      ELSE
         l_class_app_tol_pos := NULL;
         l_class_app_tol_neg := NULL;
         l_class_cost_tol_pos := NULL;
         l_class_cost_tol_neg := NULL;
      END IF;

      SELECT NVL ( approval_tolerance_positive, -1 ),
             NVL ( approval_tolerance_negative, -1 ),
             NVL ( cost_tolerance_positive, -1 ),
             NVL ( cost_tolerance_negative, -1 )
      INTO   l_head_app_tol_pos,
             l_head_app_tol_neg,
             l_head_cost_tol_pos,
             l_head_cost_tol_neg
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = l_cycle_count_header_id
      AND    organization_id = l_organization_id;

      /* Approval Tolerance Positive */
      IF l_item_app_tol_pos IS NULL THEN
         IF l_class_app_tol_pos IS NULL THEN
            x_approval_tolerance_positive := l_head_app_tol_pos;
         ELSE
            x_approval_tolerance_positive := l_class_app_tol_pos;
         END IF;
      ELSE
         x_approval_tolerance_positive := l_item_app_tol_pos;
      END IF;

      /* Approval Tolerance Negative */
      IF l_item_app_tol_neg IS NULL THEN
         IF l_class_app_tol_neg IS NULL THEN
            x_approval_tolerance_negative := l_head_app_tol_neg;
         ELSE
            x_approval_tolerance_negative := l_class_app_tol_neg;
         END IF;
      ELSE
         x_approval_tolerance_negative := l_item_app_tol_neg;
      END IF;

      /* Cost Tolerance Positive */
      IF l_class_cost_tol_pos IS NULL THEN
         x_cost_tolerance_positive := l_head_cost_tol_pos;
      ELSE
         x_cost_tolerance_positive := l_class_cost_tol_pos;
      END IF;

      /* Cost Tolerance Negative */
      IF l_class_cost_tol_neg IS NULL THEN
         x_cost_tolerance_negative := l_head_cost_tol_neg;
      ELSE
         x_cost_tolerance_negative := l_class_cost_tol_neg;
      END IF;

      /* Check the status of the pre approve flag */
      IF ( l_debug = 1 ) THEN
         print_debug ( 'Preapprove flag is: ============>' || pre_approve_flag
                     );
         print_debug ( 'Tolerances retrieved are:' );
         print_debug (    'x_approval_tolerance_positive: => '
                       || x_approval_tolerance_positive
                     );
         print_debug (    'x_approval_tolerance_negative: => '
                       || x_approval_tolerance_negative
                     );
         print_debug (    'x_cost_tolerance_positive: =====> '
                       || x_cost_tolerance_positive
                     );
         print_debug (    'x_cost_tolerance_negative: =====> '
                       || x_cost_tolerance_negative
                     );
      END IF;

      IF pre_approve_flag <> 'SERIAL' THEN
         IF pre_approve_flag <> 'TRUE' THEN
            recount_logic ( p_approval_tolerance_positive => x_approval_tolerance_positive,
                            p_approval_tolerance_negative => x_approval_tolerance_negative,
                            p_cost_tolerance_positive => x_cost_tolerance_positive,
                            p_cost_tolerance_negative => x_cost_tolerance_negative
                          );
         ELSE
            tolerance_logic ( p_approval_tolerance_positive => x_approval_tolerance_positive,
                              p_approval_tolerance_negative => x_approval_tolerance_negative,
                              p_cost_tolerance_positive => x_cost_tolerance_positive,
                              p_cost_tolerance_negative => x_cost_tolerance_negative
                            );
         END IF;
      END IF;
   END get_tolerances;

   PROCEDURE recount_logic (
      p_approval_tolerance_positive IN NUMBER,
      p_approval_tolerance_negative IN NUMBER,
      p_cost_tolerance_positive IN NUMBER,
      p_cost_tolerance_negative IN NUMBER
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***recount_logic***' );
      END IF;

      -- IF count entry has a status of RECOUNT, THEN call
      -- current_to_prior to set up the next count
      IF ( g_cc_entry.entry_status_code = 3 ) AND g_updated_prior = FALSE THEN		-- Modified for Bug 6371673
         current_to_prior ( );
      END IF;

      tolerance_logic ( p_approval_tolerance_positive => p_approval_tolerance_positive,
                        p_approval_tolerance_negative => p_approval_tolerance_negative,
                        p_cost_tolerance_positive => p_cost_tolerance_positive,
                        p_cost_tolerance_negative => p_cost_tolerance_negative
                      );
   END recount_logic;

   PROCEDURE tolerance_logic (
      p_approval_tolerance_positive IN NUMBER,
      p_approval_tolerance_negative IN NUMBER,
      p_cost_tolerance_positive IN NUMBER,
      p_cost_tolerance_negative IN NUMBER
   )
   IS
      l_adjustment_quantity NUMBER;
      l_sec_adjustment_quantity NUMBER; -- nsinghi Bug#6052831
      l_system_quantity NUMBER;
      l_sec_system_quantity NUMBER; -- nsinghi Bug#6052831
      l_pos_meas_err NUMBER;
      l_neg_meas_err NUMBER;
      l_app_tol_pos NUMBER := p_approval_tolerance_positive;
      l_app_tol_neg NUMBER := p_approval_tolerance_negative;
      l_cost_tol_pos NUMBER := p_cost_tolerance_positive;
      l_cost_tol_neg NUMBER := p_cost_tolerance_negative;
      l_adjustment_value NUMBER;
      l_approval_option_code NUMBER;
      l_parent_lpn_id NUMBER;
      l_container_enabled_flag NUMBER;
      l_container_adjustment_option NUMBER;
      l_container_discrepancy_option NUMBER;
      l_primary_uom VARCHAR2 ( 3 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***tolerance_logic***' );
      END IF;

      -- Get the item system quantity
      system_quantity ( x_system_quantity => l_system_quantity
                        , x_sec_system_quantity => l_sec_system_quantity ); -- nsinghi Bug#6052831. Call overloaded API.

      -- Get the item primary uom code
      SELECT primary_uom_code
      INTO   l_primary_uom
      FROM   MTL_SYSTEM_ITEMS
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Convert the system quantity into the count uom
      /*2977228l_system_quantity :=
         inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                      6,
                                      l_system_quantity,
                                      l_primary_uom,
                                      g_count_uom,
                                      NULL,
                                      NULL
                                    );*/
      -- Get the adjustment quantity and adjustment value
      l_adjustment_quantity := g_count_quantity - l_system_quantity;
      l_sec_adjustment_quantity := g_count_secondary_quantity - l_sec_system_quantity; -- nsinghi Bug#6052831. Added this line.
      g_cc_entry.adjustment_quantity := l_adjustment_quantity;
      g_cc_entry.secondary_adjustment_quantity := l_sec_adjustment_quantity; -- nsinghi Bug#6052831. Added this line.
      g_cc_entry.adjustment_date := SYSDATE;

      value_variance ( x_value_variance => l_adjustment_value );
      g_cc_entry.adjustment_amount := l_adjustment_value;


     /* Bug 4495880 - Checking the value of the global parameter to set the adjustment quantity
                      and adjustment value to 0*/

      IF g_condition=TRUE OR g_lpn_summary_count=TRUE  THEN --9452528,for summary count, we need adj qty to zero.

        IF ( l_debug = 1 ) THEN
            print_debug ( 'In tolerance_logic in the condition for g_condition=TRUE' );
        END IF;
       l_adjustment_quantity := 0;
       l_adjustment_value := 0;
       g_cc_entry.adjustment_quantity := l_adjustment_quantity;
       g_cc_entry.adjustment_amount := l_adjustment_value;
       -- nsinghi Bug#6052831. START
       l_sec_adjustment_quantity := 0;
       g_cc_entry.secondary_adjustment_quantity := 0;
       -- nsinghi Bug#6052831. END.

      END IF;

     /* End of fix for Bug 4495880 */


      -- Get the required information from the cycle count record.
      -- Need to use the view rather than the table to get the measurement
      -- error values
      BEGIN
         SELECT positive_measurement_error,
                negative_measurement_error,
                parent_lpn_id
         INTO   l_pos_meas_err,
                l_neg_meas_err,
                l_parent_lpn_id
         FROM   mtl_cycle_count_entries_v
         WHERE  cycle_count_entry_id = g_cc_entry.cycle_count_entry_id
         AND    organization_id = g_cc_entry.organization_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_pos_meas_err := 0;
            l_neg_meas_err := 0;
            l_parent_lpn_id := g_cc_entry.parent_lpn_id;
      END;

      -- Get the container specific information
      SELECT NVL ( container_enabled_flag, 2 ),
             NVL ( container_adjustment_option, 2 ),
             NVL ( container_discrepancy_option, 2 )
      INTO   l_container_enabled_flag,
             l_container_adjustment_option,
             l_container_discrepancy_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the cycle count header approval option code
      SELECT NVL ( approval_option_code, 1 )
      INTO   l_approval_option_code
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Adjustment quantity: ===> ' || l_adjustment_quantity );
         print_debug ( 'System quantity : ======> ' || l_system_quantity );
         print_debug ( 'Pos Measurement error: => ' || l_pos_meas_err );
         print_debug ( 'Neg Measurement error: => ' || l_neg_meas_err );
         print_debug ( 'App Tolerance pos: =====> ' || l_app_tol_pos );
         print_debug ( 'App Tolernace neg: =====> ' || l_app_tol_neg );
         print_debug ( 'Cost Tolerance pos: ====> ' || l_cost_tol_pos );
         print_debug ( 'Cost Tolerance neg: ====> ' || l_cost_tol_neg );
         print_debug ( 'Adjustment value:  =====> ' || l_adjustment_value );
         print_debug ( 'Approval option code: ==> ' || l_approval_option_code );
      END IF;

      -- Approval required for all adjustments
      IF    ( l_approval_option_code = 1 AND l_parent_lpn_id IS NULL )
         OR ( l_approval_option_code = 1 AND l_parent_lpn_id IS NOT NULL
              AND l_container_enabled_flag = 1
              AND (    l_container_adjustment_option = 2
                    OR l_container_discrepancy_option = 2
                  )
            ) THEN
         IF l_adjustment_quantity <> 0 THEN
            IF l_system_quantity <> 0 THEN
               IF l_adjustment_quantity < 0 THEN
                  IF     l_neg_meas_err IS NOT NULL
                     AND   ABS ( l_adjustment_quantity / l_system_quantity )
                         * 100 < l_neg_meas_err THEN
                     no_adj_req ( );
                  ELSE
                     out_tolerance ( );
                  END IF;
               ELSE
                  IF     l_pos_meas_err IS NOT NULL
                     AND   ABS ( l_adjustment_quantity / l_system_quantity )
                         * 100 < l_pos_meas_err THEN
                     no_adj_req ( );
                  ELSE
                     out_tolerance ( );
                  END IF;
               END IF;
            ELSE                                           /* system qty = 0 */
               out_tolerance ( );
            END IF;
         ELSE                                          /* adjustment_qty = 0 */
            no_adj_req ( );
         END IF;
      ELSE              /* IF optional_option = required IF out of tolerance */
         IF l_adjustment_quantity <> 0 THEN
            IF l_system_quantity <> 0 THEN
               IF l_adjustment_quantity < 0 THEN
                  IF     l_neg_meas_err IS NOT NULL
                     AND   ABS ( l_adjustment_quantity / l_system_quantity )
                         * 100 < l_neg_meas_err THEN
                     no_adj_req ( );
                  ELSE
                     IF (      (     l_app_tol_neg IS NOT NULL
                                 AND l_app_tol_neg >= 0
                               )
                          AND ( ABS (    (   l_adjustment_quantity
                                           / l_system_quantity
                                         )
                                      * 100
                                    ) > l_app_tol_neg
                              )
                        ) THEN
                        out_tolerance ( );
                     ELSE
                        IF (      (     l_cost_tol_neg IS NOT NULL
                                    AND l_cost_tol_neg >= 0
                                  )
                             AND ( ABS ( l_adjustment_value ) > l_cost_tol_neg
                                 )
                           ) THEN
                           out_tolerance ( );
                        ELSE
                           in_tolerance ( );
                        END IF;
                     END IF;
                  END IF;
               ELSE                            /* l_adjustment_quantity >= 0 */
                  IF     l_pos_meas_err IS NOT NULL
                     AND   ABS ( l_adjustment_quantity / l_system_quantity )
                         * 100 < l_pos_meas_err THEN
                     no_adj_req ( );
                  ELSE
                     IF (      (     l_app_tol_pos IS NOT NULL
                                 AND l_app_tol_pos >= 0
                               )
                          AND ( ABS (    (   l_adjustment_quantity
                                           / l_system_quantity
                                         )
                                      * 100
                                    ) > l_app_tol_pos
                              )
                        ) THEN
                        out_tolerance ( );
                     ELSE
                        IF (      (     l_cost_tol_pos IS NOT NULL
                                    AND l_cost_tol_pos >= 0
                                  )
                             AND ( ABS ( l_adjustment_value ) > l_cost_tol_pos
                                 )
                           ) THEN
                           out_tolerance ( );
                        ELSE
                           in_tolerance ( );
                        END IF;
                     END IF;
                  END IF;
               END IF;
            ELSE                                      /* system quantity = 0 */
               IF ( l_app_tol_pos IS NOT NULL AND l_app_tol_pos >= 0 ) THEN
                  out_tolerance ( );
               ELSE
                  IF (      (     l_cost_tol_pos IS NOT NULL
                              AND l_cost_tol_pos >= 0 )
                       AND ( l_adjustment_value > l_cost_tol_pos )
                     ) THEN
                     out_tolerance ( );
                  ELSE
                     in_tolerance ( );
                  END IF;
               END IF;
            END IF;
         ELSE                                          /* adjustment qty = 0 */
            no_adj_req ( );
         END IF;
      END IF;
   END tolerance_logic;

   PROCEDURE valids
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***valids***' );
      END IF;
       print_debug('calling from valids ');
      final_preupdate_logic ( );
   END valids;

   PROCEDURE in_tolerance
   IS
      l_approval_option_code NUMBER;
      l_parent_lpn_id NUMBER;
      l_container_enabled_flag NUMBER;
      l_container_adjustment_option NUMBER;
      l_container_discrepancy_option NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***in_tolerance***' );
      END IF;

      -- Get the required fields
      SELECT NVL ( approval_option_code, 1 )
      INTO   l_approval_option_code
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      l_parent_lpn_id := g_cc_entry.parent_lpn_id;

      -- Get the container specific information
      SELECT NVL ( container_enabled_flag, 2 ),
             NVL ( container_adjustment_option, 2 ),
             NVL ( container_discrepancy_option, 2 )
      INTO   l_container_enabled_flag,
             l_container_adjustment_option,
             l_container_discrepancy_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Approval is required for all adjustments
      IF    ( l_approval_option_code = 1 AND l_parent_lpn_id IS NULL )
         OR ( l_approval_option_code = 1 --Bug 5917964 -Added the check for approval code for lpn counts also
              AND l_parent_lpn_id IS NOT NULL
              AND l_container_enabled_flag = 1
              AND l_container_adjustment_option = 2
              AND l_container_discrepancy_option = 2
            ) THEN
         g_cc_entry.entry_status_code := 2;
      ELSE
         -- Approval is not required so complete the count entry
         g_cc_entry.entry_status_code := 5;
         g_cc_entry.approval_type := 1;
      END IF;

      valids ( );
   END in_tolerance;

   PROCEDURE out_tolerance
   IS
      l_approval_option_code NUMBER;
      l_auto_recount_flag NUMBER;
      l_max_recounts NUMBER;
      l_garbage NUMBER;
      l_parent_lpn_id NUMBER := g_cc_entry.parent_lpn_id;
      l_container_enabled_flag NUMBER;
      l_container_adjustment_option NUMBER;
      l_container_discrepancy_option NUMBER;
      l_days_until_late NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

      l_serial_count_option NUMBER; --Bug 5186993
      l_serial_number_ctrl_code NUMBER; --Bug 5186993

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***out_tolerance***' );
      END IF;

      -- Get the required values
      SELECT NVL ( approval_option_code, 1 ),
             NVL ( automatic_recount_flag, 2 ),
             NVL ( maximum_auto_recounts, 0 ),
             NVL ( days_until_late, 0 ),
             NVL ( serial_count_option, 1 )
      INTO   l_approval_option_code,
             l_auto_recount_flag,
             l_max_recounts,
             l_days_until_late,
             l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the container specific information
      SELECT NVL ( container_enabled_flag, 2 ),
             NVL ( container_adjustment_option, 2 ),
             NVL ( container_discrepancy_option, 2 )
      INTO   l_container_enabled_flag,
             l_container_adjustment_option,
             l_container_discrepancy_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

        -- Bug 5186993
         SELECT serial_number_control_code
         INTO   l_serial_number_ctrl_code
         FROM   mtl_system_items
         WHERE  inventory_item_id = g_cc_entry.inventory_item_id
         AND    organization_id = g_cc_entry.organization_id;


      -- Do more checks/validations IF the item is serial controlled
      is_serial_entered ( event => 'OUT-TOLERANCE', entered => l_garbage );

      -- No automatic recounts for this cycle count
      IF l_auto_recount_flag <> 1 THEN
         -- Approvals are not required for adjustments
         IF    ( l_approval_option_code = 2 AND l_parent_lpn_id IS NULL )
            OR ( l_approval_option_code = 2 --Bug 5917964 -Added the check for approval code for lpn counts also
                 AND l_parent_lpn_id IS NOT NULL
                 AND l_container_enabled_flag = 1
                 AND l_container_adjustment_option = 1
                 AND l_container_discrepancy_option = 1
               ) THEN
            -- Complete the count AND automatically approve it
            g_cc_entry.entry_status_code := 5;
            g_cc_entry.approval_type := 1;
         ELSE
            -- Approval is required for this adjustment
            g_cc_entry.entry_status_code := 2;
         END IF;
      ELSE
         -- Automatic recounts are allowed for this cycle count
         -- Bug# 2356835, change the < to <= since in mobile, we are updating
         -- the number of counts field in the cycle count entry beforehand
         -- in the pre_update method.  In the desktop library, this is done
         -- at the final_preupdate_logic stage which occurs after the
         -- tolerance/recount logic is done.

         -- Bug 5186993, do not set for recount for serialized items for multiple
         -- per request option.
         if (l_serial_number_ctrl_code in (1,6) OR l_serial_count_option <> 3) then
         IF NVL ( g_cc_entry.number_of_counts, 0 ) <= l_max_recounts THEN
            g_cc_entry.entry_status_code := 3;
            g_cc_entry.count_due_date := SYSDATE + l_days_until_late;
         ELSE
            -- Maximum number of recounts has already been met
            g_cc_entry.entry_status_code := 2;
         END IF;
         end if;
      END IF;

      valids ( );
   END out_tolerance;

   PROCEDURE no_adj_req
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***no_adj_req***' );
      END IF;

      g_cc_entry.entry_status_code := 5;
      g_cc_entry.adjustment_quantity := 0;
      g_cc_entry.secondary_adjustment_quantity := 0; -- nsinghi Bug#6052831
      g_cc_entry.adjustment_date := NULL;   --Bug#3640622
      valids ( );
   END no_adj_req;

   PROCEDURE pre_insert
   IS
      l_number_of_counts NUMBER := NVL ( g_cc_entry.number_of_counts, 0 );
      l_count_quantity NUMBER := g_count_quantity;
      l_count_type_code NUMBER := g_cc_entry.count_type_code;
      l_pre_approve_flag VARCHAR2 ( 20 ) := g_pre_approve_flag;
      l_cc_entry_id NUMBER;
      l_serial_number_ctrl_code NUMBER;
      l_serial_detail NUMBER;
      l_serial_entered NUMBER;
      l_serial_detail_option NUMBER;
      l_serial_count_option NUMBER;
      l_entry_status_code NUMBER := g_cc_entry.entry_status_code;
      l_total_serial_num_cnt NUMBER;
      l_cc_header_id NUMBER := g_cc_entry.cycle_count_header_id;
      l_success BOOLEAN;
      l_locator_id NUMBER := g_cc_entry.locator_id;
      l_approval_tolerance_positive NUMBER;
      l_approval_tolerance_negative NUMBER;
      l_cost_tolerance_positive NUMBER;
      l_cost_tolerance_negative NUMBER;
      l_system_quantity NUMBER;
      l_sec_system_quantity NUMBER; -- nsinghi Bug#6052831.
      l_primary_uom_quantity NUMBER;
      l_primary_uom VARCHAR2 ( 3 );
      l_adjustment_quantity NUMBER := 0;
      l_sec_adjustment_quantity NUMBER := 0; -- nsinghi Bug#6052831
      l_adjustment_value NUMBER := 0;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***pre_insert***' );
      END IF;
      duplicate_entries() ;

      -- Get the required variable values
      SELECT serial_number_control_code
      INTO   l_serial_number_ctrl_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_detail_option, 1 ),
             NVL ( serial_count_option, 1 )
      INTO   l_serial_detail_option,
             l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Set the serial detail option for the new entry
      l_serial_detail := l_serial_detail_option;
      g_cc_entry.serial_detail := l_serial_detail;

      IF ( g_cc_entry.cycle_count_entry_id IS NULL ) THEN
         SELECT mtl_cycle_count_entries_s.NEXTVAL
         INTO   l_cc_entry_id
         FROM   DUAL;

         g_cc_entry.cycle_count_entry_id := l_cc_entry_id;
         -- Bug# 2386128
         -- For unscheduled cycle count entries, the count list sequence
         -- number is the same as the cycle count entry ID
         g_cc_entry.count_list_sequence := l_cc_entry_id;
      END IF;

      IF ( l_count_type_code = 4 ) THEN
         -- Zero Count
         zero_count_logic;
      ELSE
         IF ( l_serial_number_ctrl_code IN ( 1, 6 ) ) THEN
            -- Not serial controlled
            l_number_of_counts := ( NVL ( l_number_of_counts, 0 ) + 1 );
            g_cc_entry.number_of_counts := l_number_of_counts;
            -- Get the system quantity
            system_quantity ( x_system_quantity => l_system_quantity
                              , x_sec_system_quantity => l_sec_system_quantity ); -- nsinghi Bug#6052831. Call overloaded API.

            -- Get the item primary uom code
            SELECT primary_uom_code
            INTO   l_primary_uom
            FROM   MTL_SYSTEM_ITEMS
            WHERE  inventory_item_id = g_cc_entry.inventory_item_id
            AND    organization_id = g_cc_entry.organization_id;

            -- Convert the system quantity into the count uom
            /*2977228l_system_quantity :=
               inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                            6,
                                            l_system_quantity,
                                            l_primary_uom,
                                            g_count_uom,
                                            NULL,
                                            NULL
                                          );*/
            -- Convert the count quantity into the item primary uom quantity
            l_primary_uom_quantity :=
               inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                            6,
                                            g_count_quantity,
                                            g_count_uom,
                                            l_primary_uom,
                                            NULL,
                                            NULL
                                          );

            IF ( l_number_of_counts = 1 ) THEN
               entry_to_current ( p_count_date        => SYSDATE,
                                  p_counted_by_employee_id => g_employee_id,
                                  p_system_quantity   => l_system_quantity,
                                  p_reference         => NULL,
                                  p_primary_uom_quantity => l_primary_uom_quantity,
				  p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                );
               current_to_first ( );
            ELSE
               current_to_prior ( );
               entry_to_current ( p_count_date        => SYSDATE,
                                  p_counted_by_employee_id => g_employee_id,
                                  p_system_quantity   => l_system_quantity,
                                  p_reference         => NULL,
                                  p_primary_uom_quantity => l_primary_uom_quantity,
				  p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                );
            END IF;

            IF ( l_pre_approve_flag = 'TRUE' ) THEN
               g_cc_entry.entry_status_code := 5;
               g_cc_entry.approval_type := 3;
               g_cc_entry.approver_employee_id := g_employee_id;
               print_debug('Called from pre_insert ');
               final_preupdate_logic ( );
            ELSE
               get_tolerances ( pre_approve_flag    => l_pre_approve_flag,
                                x_approval_tolerance_positive => l_approval_tolerance_positive,
                                x_approval_tolerance_negative => l_approval_tolerance_negative,
                                x_cost_tolerance_positive => l_cost_tolerance_positive,
                                x_cost_tolerance_negative => l_cost_tolerance_negative
                              );
            END IF;
         ELSIF ( l_serial_number_ctrl_code IN ( 2, 5 ) ) THEN
            -- Item is serial controlled

            IF ( l_serial_count_option = 3 ) THEN
               -- Multiple serial count option

               -- If serial details are entered, the adjustment txn should
               -- have already handled in the serial detail level or
               -- if serial detail does not entered, then get the tolerance
               is_serial_entered ( 'WHEN-VALIDATE-RECORD', l_serial_entered );

               IF ( l_serial_entered = 0 ) THEN
                  get_tolerances ( pre_approve_flag    => l_pre_approve_flag,
                                   x_approval_tolerance_positive => l_approval_tolerance_positive,
                                   x_approval_tolerance_negative => l_approval_tolerance_negative,
                                   x_cost_tolerance_positive => l_cost_tolerance_positive,
                                   x_cost_tolerance_negative => l_cost_tolerance_negative
                                 );
               ELSIF ( l_serial_entered = 1 ) THEN
                  IF ( l_entry_status_code = 5 ) THEN
                     -- Completed count entries
                     g_cc_entry.approval_date := SYSDATE;
                  END IF;

                  l_number_of_counts := ( NVL ( l_number_of_counts, 0 ) + 1 );
                  g_cc_entry.number_of_counts := l_number_of_counts;
                  -- Get the system quantity
                  system_quantity ( x_system_quantity => l_system_quantity
                                    , x_sec_system_quantity => l_sec_system_quantity ); -- nsinghi Bug#6052831. Call overloaded API.

                  -- Get the item primary uom code
                  SELECT primary_uom_code
                  INTO   l_primary_uom
                  FROM   MTL_SYSTEM_ITEMS
                  WHERE  inventory_item_id = g_cc_entry.inventory_item_id
                  AND    organization_id = g_cc_entry.organization_id;

                  -- Convert the system quantity into the count uom
                  /*2977228l_system_quantity :=
                     inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                                  6,
                                                  l_system_quantity,
                                                  l_primary_uom,
                                                  g_count_uom,
                                                  NULL,
                                                  NULL
                                                );*/
                  -- Convert the count quantity into the item primary uom quantity
                  l_primary_uom_quantity :=
                     inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                                  6,
                                                  g_count_quantity,
                                                  g_count_uom,
                                                  l_primary_uom,
                                                  NULL,
                                                  NULL
                                                );

                  IF ( l_number_of_counts = 1 ) THEN
                     entry_to_current ( p_count_date        => SYSDATE,
                                        p_counted_by_employee_id => g_employee_id,
                                        p_system_quantity   => l_system_quantity,
                                        p_reference         => NULL,
                                        p_primary_uom_quantity => l_primary_uom_quantity,
					p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                      );
                     current_to_first ( );
                  ELSE
                     current_to_prior ( );
                     entry_to_current ( p_count_date        => SYSDATE,
                                        p_counted_by_employee_id => g_employee_id,
                                        p_system_quantity   => l_system_quantity,
                                        p_reference         => NULL,
                                        p_primary_uom_quantity => l_primary_uom_quantity,
					p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                      );
                  END IF;

                  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
                  SET LOCATOR_ID = l_locator_id
                  WHERE  CYCLE_COUNT_ID = l_cc_entry_id
                  AND    TRANSACTION_SOURCE_ID = l_cc_header_id
                  AND    LOCATOR_ID = -1;

                  -- Bug 5186993, if recount unmarking the serials and re-setting serials in MCSN.
                  if (l_entry_status_code = 3) then
                         unmark(l_cc_entry_id);
                         UPDATE MTL_CC_SERIAL_NUMBERS
                         SET
                                UNIT_STATUS_CURRENT = DECODE((NVL(POS_ADJUSTMENT_QTY,0) -
                                      NVL(NEG_ADJUSTMENT_QTY,0)), 1, 2, -1, 1, UNIT_STATUS_CURRENT),
                                POS_ADJUSTMENT_QTY = 0,
                                NEG_ADJUSTMENT_QTY = 0,
                                APPROVAL_CONDITION = NULL
                         WHERE CYCLE_COUNT_ENTRY_ID = l_cc_entry_id;
                  end if;

               END IF;
            -- Single serial count
            ELSIF ( l_serial_count_option = 2 ) THEN
               -- Check if an adjustment txn is necessary
               -- Get the system quantity
               system_quantity ( x_system_quantity => l_system_quantity
                                 , x_sec_system_quantity => l_sec_system_quantity ); -- nsinghi Bug#6052831. Call overloaded API.

               IF ( l_system_quantity <> 0 ) THEN
                  g_serial_out_tolerance := FALSE;
               ELSE
                  g_serial_out_tolerance := TRUE;
               END IF;

               -- Get and set the adjustment quantity and adjustment value
               l_adjustment_quantity := g_count_quantity - l_system_quantity;
               g_cc_entry.adjustment_quantity := l_adjustment_quantity;
	       -- nsinghi bug#6052831 START.
	       IF g_count_secondary_quantity IS NOT NULL AND l_sec_system_quantity IS NOT NULL THEN
	          l_sec_adjustment_quantity := g_count_secondary_quantity - l_sec_system_quantity;
                  g_cc_entry.secondary_adjustment_quantity := l_sec_adjustment_quantity;
	       END IF;
	       -- nsinghi bug#6052831 END.
               g_cc_entry.adjustment_date := SYSDATE;
               value_variance ( x_value_variance => l_adjustment_value );
               g_cc_entry.adjustment_amount := l_adjustment_value;
               -- Update the number of counts
               l_number_of_counts := ( NVL ( l_number_of_counts, 0 ) + 1 );
               g_cc_entry.number_of_counts := l_number_of_counts;

               -- Get the item primary uom code
               SELECT primary_uom_code
               INTO   l_primary_uom
               FROM   MTL_SYSTEM_ITEMS
               WHERE  inventory_item_id = g_cc_entry.inventory_item_id
               AND    organization_id = g_cc_entry.organization_id;

               -- Convert the system quantity into the count uom
               /*2977228l_system_quantity :=
                  inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                               6,
                                               l_system_quantity,
                                               l_primary_uom,
                                               g_count_uom,
                                               NULL,
                                               NULL
                                             );*/
               -- Convert the count quantity into the item primary uom quantity
               l_primary_uom_quantity :=
                  inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                               6,
                                               g_count_quantity,
                                               g_count_uom,
                                               l_primary_uom,
                                               NULL,
                                               NULL
                                             );

               IF ( l_number_of_counts = 1 ) THEN
                  entry_to_current ( p_count_date        => SYSDATE,
                                     p_counted_by_employee_id => g_employee_id,
                                     p_system_quantity   => l_system_quantity,
                                     p_reference         => NULL,
                                     p_primary_uom_quantity => l_primary_uom_quantity,
				     p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                   );
                  current_to_first ( );
               ELSE
                  current_to_prior ( );
                  entry_to_current ( p_count_date        => SYSDATE,
                                     p_counted_by_employee_id => g_employee_id,
                                     p_system_quantity   => l_system_quantity,
                                     p_reference         => NULL,
                                     p_primary_uom_quantity => l_primary_uom_quantity,
				     p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                   );
               END IF;

               -- Calling new_serial_number which in turn will call
               -- final_preupdate_logic to process any adjustments if necessary
               new_serial_number ( );
            END IF;
         END IF;
      END IF;
   END pre_insert;

   PROCEDURE pre_update
   IS
      l_number_of_counts NUMBER := NVL ( g_cc_entry.number_of_counts, 0 );
      l_count_quantity NUMBER := g_count_quantity;
      l_count_type_code NUMBER := g_cc_entry.count_type_code;
      l_pre_approve_flag VARCHAR2 ( 20 ) := g_pre_approve_flag;
      l_cc_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      l_old_num_counts NUMBER;
      l_serial_number_ctrl_code NUMBER;
      l_serial_detail NUMBER := g_cc_entry.serial_detail;
      l_serial_entered NUMBER := 0;
      l_serial_detail_option NUMBER;
      l_serial_count_option NUMBER;
      l_entry_status_code NUMBER := g_cc_entry.entry_status_code;
      l_total_serial_num_cnt NUMBER;
      l_approval_tolerance_positive NUMBER;
      l_approval_tolerance_negative NUMBER;
      l_cost_tolerance_positive NUMBER;
      l_cost_tolerance_negative NUMBER;
      l_system_quantity NUMBER;
      l_sec_system_quantity NUMBER; -- nsinghi bug#6052831
      l_primary_uom_quantity NUMBER;
      l_primary_uom VARCHAR2 ( 3 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );


      /* Bug 4495880 -Added the local variables for the lpn details from wlpn*/

      l_lpn_subinv  VARCHAR2(10) ;
      l_lpn_locator_id  NUMBER ;
      l_lpn_context  NUMBER;

      /* End of fix for Bug 4495880 */

      /* Added tbe below 2 variables for Bug#5604139 */
         l_adjustment_quantity NUMBER := 0;
         l_adjustment_value NUMBER := 0;
      /* End of fix for Bug 5604139 */
      l_sec_adjustment_quantity NUMBER; -- nsinghi Bug#6052831

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***pre_update***' );
      END IF;

      /* Bug 4495880-Added the debug messages to check the values of the global constants */

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Value of g_cc_entry.subinventory:'|| g_cc_entry.subinventory );
            print_debug ( 'Value of g_cc_entry.locator_id:' || g_cc_entry.locator_id );
            print_debug ( 'Value of g_cc_entry.parent_lpn_id ' || g_cc_entry.parent_lpn_id  );
            print_debug ( 'Value of g_count_quantity ' || g_count_quantity  );
         END IF;

         /* End of fix for Bug 4495880 */

         /* Bug 4495880 -For counts with lpns, checking if there is a discrepancy in location
                         of the lpn from mcce and wlpn . Further for the context 1 lpns, if
                         a count quantity of 0 is entered, setting the global constant to TRUE */

         IF ( g_cc_entry.parent_lpn_id IS NOT NULL ) THEN

            SELECT NVL ( subinventory_code, '###' ),
                   NVL ( locator_id, -99 ),
                   lpn_context
            INTO   l_lpn_subinv,
                   l_lpn_locator_id,
                   l_lpn_context
            FROM   WMS_LICENSE_PLATE_NUMBERS
            WHERE  lpn_id = g_cc_entry.parent_lpn_id ;

            IF ( l_debug = 1 ) THEN
                 print_debug ( 'l_lpn_subinv: ===> ' || l_lpn_subinv );
                 print_debug ( 'l_lpn_locator_id: => ' || l_lpn_locator_id );
                 print_debug ( 'l_lpn_context: => ' || l_lpn_context );
            END IF;


            IF (l_lpn_subinv <> g_cc_entry.subinventory
                OR l_lpn_locator_id <> g_cc_entry.locator_id ) THEN

                 IF ( l_debug = 1 ) THEN
                      print_debug ( 'Location from wlpn does not match that of mcce' );
                 END IF;

                 IF l_lpn_context=1 and g_count_quantity = 0 AND g_lpn_summary_count = FALSE THEN --9452528,added summary check

                      IF ( l_debug = 1 ) THEN
                         print_debug ( 'LPN context is 1 and quantity entered is 0 so setting the paramter g_condition to TRUE' );
                      END IF;

                      g_condition:=TRUE ;

                 END IF;

            END IF;

         END IF;

         /* End of fix for Bug 4495880  */


      -- Get the required variable values
      SELECT serial_number_control_code
      INTO   l_serial_number_ctrl_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_detail_option, 1 ),
             NVL ( serial_count_option, 1 )
      INTO   l_serial_detail_option,
             l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Compare the current entry's number of counts with the value
      -- in the record stored in the table
      SELECT NVL ( number_of_counts, 0 )
      INTO   l_old_num_counts
      FROM   mtl_cycle_count_entries
      WHERE  cycle_count_entry_id = l_cc_entry_id;

      IF ( l_old_num_counts > l_number_of_counts ) THEN
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_DUPLICATE_COUNT_UPDATE' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( l_count_type_code = 4 ) THEN
         -- Zero Count
         zero_count_logic ( );
      ELSE
         IF ( l_serial_number_ctrl_code IN ( 1, 6 ) ) THEN
            -- Not serial controlled

            l_number_of_counts := ( NVL ( l_number_of_counts, 0 ) + 1 );
            g_cc_entry.number_of_counts := l_number_of_counts;
            -- Get the system quantity
            -- nsinghi bug#6052831. Call the overloaded procedure.
            -- system_quantity ( x_system_quantity => l_system_quantity );
            system_quantity (x_system_quantity => l_system_quantity
                             , x_sec_system_quantity => l_sec_system_quantity);

            -- Get the item primary uom code
            SELECT primary_uom_code
            INTO   l_primary_uom
            FROM   MTL_SYSTEM_ITEMS
            WHERE  inventory_item_id = g_cc_entry.inventory_item_id
            AND    organization_id = g_cc_entry.organization_id;

            -- Convert the system quantity into the count uom
            /*2977228l_system_quantity :=
               inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                            6,
                                            l_system_quantity,
                                            l_primary_uom,
                                            g_count_uom,
                                            NULL,
                                            NULL
                                          );*/
            -- Convert the count quantity into the item primary uom quantity
            l_primary_uom_quantity :=
               inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                            6,
                                            g_count_quantity,
                                            g_count_uom,
                                            l_primary_uom,
                                            NULL,
                                            NULL
                                          );

            IF ( l_number_of_counts = 1 ) THEN
               entry_to_current ( p_count_date        => SYSDATE,
                                  p_counted_by_employee_id => g_employee_id,
                                  p_system_quantity   => l_system_quantity,
                                  p_reference         => NULL,
                                  p_primary_uom_quantity => l_primary_uom_quantity,
                                  p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                );
               current_to_first ( );
            ELSE
               current_to_prior ( );
	       g_updated_prior := TRUE;				-- Bug 6371673
               entry_to_current ( p_count_date        => SYSDATE,
                                  p_counted_by_employee_id => g_employee_id,
                                  p_system_quantity   => l_system_quantity,
                                  p_reference         => NULL,
                                  p_primary_uom_quantity => l_primary_uom_quantity,
                                  p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                );
            END IF;

            IF ( l_pre_approve_flag = 'TRUE' ) THEN
               g_cc_entry.entry_status_code := 5;
               g_cc_entry.approval_type := 3;
               g_cc_entry.approver_employee_id := g_employee_id;
               print_debug('from pre_update : 1');
               final_preupdate_logic ( );
            ELSE
               get_tolerances ( pre_approve_flag    => l_pre_approve_flag,
                                x_approval_tolerance_positive => l_approval_tolerance_positive,
                                x_approval_tolerance_negative => l_approval_tolerance_negative,
                                x_cost_tolerance_positive => l_cost_tolerance_positive,
                                x_cost_tolerance_negative => l_cost_tolerance_negative
                              );
            END IF;
	    g_updated_prior := FALSE;	-- Bug 6371673
         ELSIF ( l_serial_number_ctrl_code IN ( 2, 5 ) ) THEN
            -- Serial controlled item
            IF ( l_serial_count_option = 3 ) THEN
               -- Multiple serial per request
               is_serial_entered ( 'WHEN-VALIDATE-RECORD', l_serial_entered );

                --Added the or condition in the below if statement for bug#4424743
               IF ( l_serial_entered = 0 or (l_serial_entered = 1 and g_count_quantity = 0)) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Serial entered: ' || l_serial_entered );
                  END IF;

                  get_tolerances ( pre_approve_flag    => l_pre_approve_flag,
                                   x_approval_tolerance_positive => l_approval_tolerance_positive,
                                   x_approval_tolerance_negative => l_approval_tolerance_negative,
                                   x_cost_tolerance_positive => l_cost_tolerance_positive,
                                   x_cost_tolerance_negative => l_cost_tolerance_negative
                                 );
               ELSIF ( l_serial_entered = 1 ) THEN
                  -- If the serial number was entered, then make sure that the number
                  -- of serial_number marked present matches the quantity entered.
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Serial entered: ' || l_serial_entered );
                  END IF;

                  SELECT SUM ( DECODE ( UNIT_STATUS_CURRENT, 1, 1, 0 ) )
                  INTO   l_total_serial_num_cnt
                  FROM   MTL_CC_SERIAL_NUMBERS
                  WHERE  CYCLE_COUNT_ENTRY_ID = l_cc_entry_id;

                  IF ( l_total_serial_num_cnt <> l_count_quantity ) THEN
                     FND_MESSAGE.SET_NAME ( 'INV',
                                            'INV_CC_SERIAL_DETAIL_MISMATCH'
                                          );
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  IF ( l_entry_status_code = 5 ) THEN
                     -- Completed count entries
                     g_cc_entry.approval_date := SYSDATE;

                     IF ( l_debug = 1 ) THEN
                        print_debug ( 'Multiple entry has been completed so call final_preupdate_logic'
                                    );
                     END IF;

                     -- Call this to process LPN discrepancies if any
                     IF ( l_debug = 1 ) THEN
                        print_debug ( 'This is to process LPN discrepancy if any exist'
                                    );
                     END IF;
                     print_debug('from pre_update : 2');
                     final_preupdate_logic ( );
                  END IF;
               END IF;

               -- Bug# 2379128
               -- The following code before was only called when
               -- l_serial_entered was equal to 1.  We need to do this
               -- updating even if l_serial_entered is equal to 0
               l_number_of_counts := ( NVL ( l_number_of_counts, 0 ) + 1 );
               g_cc_entry.number_of_counts := l_number_of_counts;
               -- Get the system quantity
               system_quantity ( x_system_quantity => l_system_quantity
                                 , x_sec_system_quantity => l_sec_system_quantity ); -- nsinghi Bug#6052831. Call overloaded API.

               -- Get the item primary uom code
               SELECT primary_uom_code
               INTO   l_primary_uom
               FROM   MTL_SYSTEM_ITEMS
               WHERE  inventory_item_id = g_cc_entry.inventory_item_id
               AND    organization_id = g_cc_entry.organization_id;

               -- Convert the system quantity into the count uom
               /*2977228l_system_quantity :=
                  inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                               6,
                                               l_system_quantity,
                                               l_primary_uom,
                                               g_count_uom,
                                               NULL,
                                               NULL
                                             );*/
               -- Convert the count quantity into the item primary uom quantity
               l_primary_uom_quantity :=
                  inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                               6,
                                               g_count_quantity,
                                               g_count_uom,
                                               l_primary_uom,
                                               NULL,
                                               NULL
                                             );

               IF ( l_number_of_counts = 1 ) THEN
                  entry_to_current ( p_count_date        => SYSDATE,
                                     p_counted_by_employee_id => g_employee_id,
                                     p_system_quantity   => l_system_quantity,
                                     p_reference         => NULL,
                                     p_primary_uom_quantity => l_primary_uom_quantity,
                                     p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                   );
                  current_to_first ( );
               ELSE
                  current_to_prior ( );
                  entry_to_current ( p_count_date        => SYSDATE,
                                     p_counted_by_employee_id => g_employee_id,
                                     p_system_quantity   => l_system_quantity,
                                     p_reference         => NULL,
                                     p_primary_uom_quantity => l_primary_uom_quantity,
                                     p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                   );
               END IF;
            -- Bug 5186993, if recount unmarking the serials and re-setting serials in MCSN.
             if (l_entry_status_code = 3) then
                    unmark(l_cc_entry_id);
                     UPDATE MTL_CC_SERIAL_NUMBERS
                         SET
                                UNIT_STATUS_CURRENT = DECODE((NVL(POS_ADJUSTMENT_QTY,0) -
                                      NVL(NEG_ADJUSTMENT_QTY,0)), 1, 2, -1, 1, UNIT_STATUS_CURRENT),
                                POS_ADJUSTMENT_QTY = 0,
                                NEG_ADJUSTMENT_QTY = 0,
                                APPROVAL_CONDITION = NULL
                         WHERE CYCLE_COUNT_ENTRY_ID = l_cc_entry_id;
             end if;
            ELSIF ( l_serial_count_option = 2 ) THEN
               -- Single serial per request
               g_serial_out_tolerance := FALSE;
               -- Update the number of counts
               l_number_of_counts := ( NVL ( l_number_of_counts, 0 ) + 1 );
               g_cc_entry.number_of_counts := l_number_of_counts;
               -- Get the system quantity
               system_quantity ( x_system_quantity => l_system_quantity
                                 , x_sec_system_quantity => l_sec_system_quantity ); -- nsinghi Bug#6052831. Call overloaded API.


            /* Added tbe below code for bug#5604139 */
            -- Get and set the adjustment quantity and adjustment value
            l_adjustment_quantity := g_count_quantity - l_system_quantity;
            g_cc_entry.adjustment_quantity := l_adjustment_quantity;
	    -- nsinghi bug#6052831 START.
	    IF g_count_secondary_quantity IS NOT NULL AND l_sec_system_quantity IS NOT NULL THEN
	       l_sec_adjustment_quantity := g_count_secondary_quantity - l_sec_system_quantity;
               g_cc_entry.secondary_adjustment_quantity := l_sec_adjustment_quantity;
	    END IF;
	    -- nsinghi bug#6052831 END.
            g_cc_entry.adjustment_date := SYSDATE;
            value_variance ( x_value_variance => l_adjustment_value );
            g_cc_entry.adjustment_amount := l_adjustment_value;
            /* End of fix for Bug 5604139*/


               -- Get the item primary uom code
               SELECT primary_uom_code
               INTO   l_primary_uom
               FROM   MTL_SYSTEM_ITEMS
               WHERE  inventory_item_id = g_cc_entry.inventory_item_id
               AND    organization_id = g_cc_entry.organization_id;

               -- Convert the system quantity into the count uom
               /*2977228l_system_quantity :=
                  inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                               6,
                                               l_system_quantity,
                                               l_primary_uom,
                                               g_count_uom,
                                               NULL,
                                               NULL
                                             );*/
               -- Convert the count quantity into the item primary uom quantity
               l_primary_uom_quantity :=
                  inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                               6,
                                               g_count_quantity,
                                               g_count_uom,
                                               l_primary_uom,
                                               NULL,
                                               NULL
                                             );

               IF ( l_count_quantity <> l_system_quantity ) THEN
                  mark ( );
               END IF;

               IF ( l_number_of_counts = 1 ) THEN
                  entry_to_current ( p_count_date        => SYSDATE,
                                     p_counted_by_employee_id => g_employee_id,
                                     p_system_quantity   => l_system_quantity,
                                     p_reference         => NULL,
                                     p_primary_uom_quantity => l_primary_uom_quantity,
				     p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                   );
                  current_to_first ( );
               ELSE
                  current_to_prior ( );
                  entry_to_current ( p_count_date        => SYSDATE,
                                     p_counted_by_employee_id => g_employee_id,
                                     p_system_quantity   => l_system_quantity,
                                     p_reference         => NULL,
                                     p_primary_uom_quantity => l_primary_uom_quantity,
				     p_sec_system_quantity => l_sec_system_quantity -- nsinghi bug#6052831 Pass sec qty.
                                   );
               END IF;

               -- Call existing serial number which in turn will call
               -- final_preupdate_logic if an adjustment is needed
               existing_serial_number ( );

               IF ( l_entry_status_code = 5 ) THEN
                  -- Completed count entries
                  g_cc_entry.approval_date := SYSDATE;
               END IF;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE FND_API.G_EXC_ERROR;
   END pre_update;

   PROCEDURE final_preupdate_logic
   IS
      l_entry_status_code NUMBER := g_cc_entry.entry_status_code;
      l_number_of_counts NUMBER := g_cc_entry.number_of_counts;
      l_adjustment_quantity NUMBER := g_cc_entry.adjustment_quantity;
      l_sec_adjustment_quantity NUMBER := g_cc_entry.secondary_adjustment_quantity; -- nsinghi bug#6052831
      l_transaction_id NUMBER;
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_cc_header_id NUMBER := g_cc_entry.cycle_count_header_id;
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_sub     VARCHAR2 ( 10 ) := g_cc_entry.subinventory;
      l_txn_quantity NUMBER := g_cc_entry.adjustment_quantity;
      l_sec_txn_quantity NUMBER := g_cc_entry.secondary_adjustment_quantity;--Added for bug 7429124
      l_txn_uom VARCHAR2 ( 3 ) := g_cc_entry.count_uom_current;
      l_lot_num VARCHAR2 ( 80 ) := g_cc_entry.lot_number;--Bug 6120140 Increased lot size to 80
      l_lot_exp_date DATE;
      l_rev     VARCHAR2 ( 3 ) := g_cc_entry.revision;
      l_locator_id NUMBER := g_cc_entry.locator_id;
      l_txn_ref VARCHAR2 ( 240 ) := NULL;
      l_reason_id NUMBER := g_cc_entry.transaction_reason_id;
      l_txn_header_id NUMBER := NVL ( g_txn_header_id, -2 );
      l_txn_temp_id NUMBER;
      l_user_id NUMBER := g_user_id;
      l_login_id NUMBER := g_login_id;
      l_txn_proc_mode NUMBER := g_txn_proc_mode;
      l_txn_acct_id NUMBER;
      l_success_flag NUMBER;
      l_p_uom_qty NUMBER;
      l_cycle_count_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      l_from_uom VARCHAR2 ( 3 );
      l_to_uom  VARCHAR2 ( 3 );
      l_txn_date DATE := SYSDATE;
      l_serial_number VARCHAR2 ( 30 ) := g_cc_entry.serial_number;
      l_serial_prefix VARCHAR2 ( 30 );
      l_lpn_id  NUMBER := g_cc_entry.parent_lpn_id;
      l_cost_group_id NUMBER := g_cc_entry.cost_group_id;
      l_system_quantity NUMBER;
      l_primary_uom_quantity NUMBER;
      -- Variables used for handling serial discrepancies
      l_msn_subinv VARCHAR2 ( 10 );
      l_msn_lot_number VARCHAR2 ( 30 );
      l_msn_locator_id NUMBER;
      l_msn_revision VARCHAR2 ( 3 );
      l_current_status NUMBER;
      l_adj_qty NUMBER;
      l_msn_lpn_id NUMBER;
      l_serial_number_ctrl_code NUMBER;
      l_serial_count_option NUMBER;
      -- Variables used for handling lpn discrepancies
      l_lpn_subinv VARCHAR2 ( 10 );
      l_lpn_locator_id NUMBER;
      l_lpn_discrepancy_flag NUMBER := 0;
      l_temp_lpn_count NUMBER;
      l_item_name VARCHAR2 ( 100 );
      -- Bug # 2743382

      v_available_quantity NUMBER;
      v_entry_status_code NUMBER;
      x_return_status VARCHAR2 ( 10 );
      x_qoh     NUMBER;
      x_att     NUMBER;
      v_ser_code NUMBER;
      v_lot_code NUMBER;
      v_rev_code NUMBER;
      v_is_ser_controlled BOOLEAN := FALSE;
      v_is_lot_controlled BOOLEAN := FALSE;
      v_is_rev_controlled BOOLEAN := FALSE;
      l_rqoh    NUMBER;
      l_qr      NUMBER;
      l_qs      NUMBER;
      l_atr     NUMBER;
      l_msg_count NUMBER;
      l_msg_data VARCHAR2 ( 2000 );
      l_parent_lpn_id NUMBER;
      l_neg_inv_rcpt_code NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_allow_neg_onhand_prof_val NUMBER;-- 4870490
      l_sec_uom VARCHAR2(3)   :=  g_count_secondary_uom      ;   -- INVCONV,NSRIVAST
      l_sec_qty NUMBER   :=  g_count_secondary_quantity ;   -- INVCONV,NSRIVAST
      -- nsinghi bug#6052831
      l_sqoh    NUMBER;
      l_srqoh   NUMBER;
      l_sqr     NUMBER;
      l_sqs     NUMBER;
      l_satt    NUMBER;
      l_satr    NUMBER;
      -- nsinghi bug#6052831
    BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***final_preupdate_logic***' );
      END IF;

      /* Bug 5704910*/
      --Clearing the quantity tree cache
        inv_quantity_tree_pub.clear_quantity_cache;

      -- Get the required variable values
      -- Get the item primary uom code
      SELECT primary_uom_code
      INTO   l_to_uom
      FROM   MTL_SYSTEM_ITEMS
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT serial_number_control_code
      INTO   l_serial_number_ctrl_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_count_option, 1 ),
             NVL ( inventory_adjustment_account, -1 )
      INTO   l_serial_count_option,
             l_txn_acct_id
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT concatenated_segments
      INTO   l_item_name
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = l_item_id AND organization_id = l_org_id;

-- Bug 3296675, we need to delete cycle count reservations before checking for availability.
      IF ( l_entry_status_code = 5 ) THEN
          delete_reservation ( );
      END IF;

      -- Bug # 2743382

      SELECT negative_inv_receipt_code
      INTO   l_neg_inv_rcpt_code --Negative Balance  1:Allowed   2:Disallowed
      FROM   mtl_parameters
      WHERE  organization_id = l_org_id;

       --4870490
         l_allow_neg_onhand_prof_val := NVL(FND_PROFILE.VALUE('INV_ALLOW_CC_TXNS_ONHAND_NEG'),2);

         print_debug ( 'l_neg_inv_rcpt_mode '||l_neg_inv_rcpt_code );
         print_debug ( 'l_allow_neg_onhand_prof_val '||l_allow_neg_onhand_prof_val );


 -- Bug number 4469742 commented the IF clause here AS per the discussion WITH the PM
  -- for the complete opinion from the PM please refer to the update in the bug
  --*** JSHERMAN  07/01/05 02:44 pm ***
  -- after this the check IF (v_available_quantity + v_adjustment_quantity < 0)  will happen
  -- irrespective of the the l_neg_inv_rcpt_code flag value

      --IF ( l_neg_inv_rcpt_code = 2 ) THEN

        -- print_debug ( 'l_neg_inv_rcpt_mode = 2' );
         SELECT serial_number_control_code,
                lot_control_code,
                revision_qty_control_code
         INTO   v_ser_code,
                v_lot_code,
                v_rev_code
         FROM   mtl_system_items
         WHERE  inventory_item_id = l_item_id AND organization_id = l_org_id;

         IF ( v_ser_code <> 1 ) THEN
            v_is_ser_controlled := TRUE;
         END IF;

         IF ( v_lot_code <> 1 ) THEN
            v_is_lot_controlled := TRUE;
         END IF;

         IF ( v_rev_code <> 1 ) THEN
            v_is_rev_controlled := TRUE;
         END IF;

         /* Bug 5725198-Checking if the count is for an LPN, in that case, query quantity tree
                           for the LPN along with it's subinventory/location. */

           IF ( l_lpn_id IS NOT NULL ) THEN
             SELECT NVL ( subinventory_code, '###' ),
                    NVL ( locator_id, -99 )
             INTO   l_lpn_subinv,
                    l_lpn_locator_id
             FROM   WMS_LICENSE_PLATE_NUMBERS
             WHERE  lpn_id = l_lpn_id;

             IF ( l_debug = 1 ) THEN
                  print_debug ( 'l_lpn_subinv: ===> ' || l_lpn_subinv );
                  print_debug ( 'l_lpn_locator_id: => ' || l_lpn_locator_id );
             END IF;

             IF  ( l_lpn_subinv <> '###' AND l_lpn_locator_id <> -99 ) THEN

               inv_quantity_tree_pub.query_quantities ( p_api_version_number => 1.0,
                                                        p_init_msg_lst      => 'F',
                                                        x_return_status     => x_return_status,
                                                        x_msg_count         => l_msg_count,
                                                        x_msg_data          => l_msg_data,
                                                        p_organization_id   => l_org_id,
                                                        p_inventory_item_id => l_item_id,
                                                        p_tree_mode         => 1,
                                                        p_is_revision_control => v_is_rev_controlled,
                                                        p_is_lot_control    => v_is_lot_controlled,
                                                        p_is_serial_control => v_is_ser_controlled,
                                                        p_demand_source_type_id => NULL,
                                                        p_revision          => l_rev,
                                                        p_lot_number        => l_lot_num,
                                                        p_lot_expiration_date => l_lot_exp_date,
                                                        p_subinventory_code => l_lpn_subinv,
                                                        p_locator_id        => l_lpn_locator_id,
                                                        p_onhand_source     => 3,
                                                        p_lpn_id            => l_lpn_id,
                                                        x_qoh               => x_qoh,
                                                        x_rqoh              => l_rqoh,
                                                        x_qr                => l_qr,
                                                        x_qs                => l_qs,
                                                        x_att               => x_att,
                                                        x_atr               => l_atr
                                                      );

               v_available_quantity:= x_att;

             ELSE
               v_available_quantity:= 0;

             END IF ;

             print_debug ( 'After querying with lpn and lpn location');
             print_debug ( 'v_available_quantity: '||v_available_quantity);
             print_debug ( 'x_qoh:'|| x_qoh );
             print_debug ( 'l_rqoh:'|| l_rqoh );
             print_debug ( 'l_qr:'|| l_qr );
             print_debug ( 'l_qs:'|| l_qs );
             print_debug ( 'l_atr:'||l_atr );
             print_debug ( 'l_adjustment_quantity '||l_adjustment_quantity );
             print_debug ( 'l_sec_adjustment_quantity '||l_sec_adjustment_quantity ); -- nsinghi bug#6052831
             print_debug ( 'v_entry_status_code '||v_entry_status_code );
             print_debug ( 'l_entry_status_code '||l_entry_status_code );

           ELSE --Querying qty tree as before
/*
        End of Bug 5725198
*/

         inv_quantity_tree_pub.query_quantities ( p_api_version_number => 1.0,
                                                  p_init_msg_lst      => 'F',
                                                  x_return_status     => x_return_status,
                                                  x_msg_count         => l_msg_count,
                                                  x_msg_data          => l_msg_data,
                                                  p_organization_id   => l_org_id,
                                                  p_inventory_item_id => l_item_id,
                                                  p_tree_mode         => 1,
                                                  p_is_revision_control => v_is_rev_controlled,
                                                  p_is_lot_control    => v_is_lot_controlled,
                                                  p_is_serial_control => v_is_ser_controlled,
                                                  p_demand_source_type_id => NULL,
                                                  p_revision          => l_rev,
                                                  p_lot_number        => l_lot_num,
                                                  p_lot_expiration_date => l_lot_exp_date,
                                                  p_subinventory_code => l_sub,
                                                  p_locator_id        => l_locator_id,
                                                  p_onhand_source     => 3,
                                                  x_qoh               => x_qoh,
                                                  x_rqoh              => l_rqoh,
                                                  x_qr                => l_qr,
                                                  x_qs                => l_qs,
                                                  x_att               => x_att,
                                                  x_atr               => l_atr
                                                );
         v_available_quantity := x_att;

        print_debug ( 'v_available_quantity '||v_available_quantity);
        print_debug ( 'x_qoh '|| x_qoh);
        print_debug ( 'l_rqoh '|| l_rqoh);
        print_debug ( 'l_qr '|| l_qr);
        print_debug ( 'l_qs '|| l_qs);
        print_debug ( 'l_atr '||l_atr );
        print_debug ( 'l_adjustment_quantity '||l_adjustment_quantity );
        print_debug ( 'l_sec_adjustment_quantity '||l_sec_adjustment_quantity ); -- nsinghi bug#6052831
        print_debug ( 'v_entry_status_code '||v_entry_status_code );
        print_debug ( 'l_entry_status_code '||l_entry_status_code );

        /* End of fix for Bug 5725198 */
         END IF;
        /* End of fix for Bug 5725198 */


         /*Bug Number 4870490
         Profile Value : Yes-1
                         No/NUll- 2
         l_neg_rcpt_code 1- Allow
                         2-Disallow

         Approval Option  L-Neg_rcpot Code   Profile Value    Behaviour

         Always             1                 1                Allows Approval
         Always             1                 2                On Approval Error is shown
         Always             2                 1                On Approval Error is shown
         Always             2                 2                On Approval Error is shown


         Approval Option  L-Neg_rcpot Code   Profile Value    Behaviour

         Never             1                 1                Adjustments happen at entry
         Never             1                 2                Adjustments Deferrred to Approval
         Never             2                 1                Adjustments Deferrred to Approval
         Never             2                 2                Adjustments Deferrred to Approval

         */

	 --Bug 6601010 - Added a condition to check if it is a subxfer of the LPN. Otherwise earlier check
         IF  ( (l_lpn_subinv <> '###' AND l_lpn_locator_id <> -99) AND
	     (l_lpn_subinv <> g_cc_entry.subinventory OR l_lpn_locator_id <> g_cc_entry.locator_id ))
         THEN
	     print_debug ( 'In condition for discrepancy');

	     IF  x_qoh <>  v_available_quantity AND l_entry_status_code = 5 THEN
	     g_cc_entry.approval_type := NULL;
	     g_cc_entry.approver_employee_id := NULL;
	     g_cc_entry.approval_date := NULL;
	     -- Reset the entry status code to 2: Approval required
	     -- Do this for both the local variable as well as the global cycle count
	     -- entry record
	     g_cc_entry.entry_status_code := 2;
	     l_entry_status_code := 2;
	     END IF;
         ELSE
           --Bug 5095970, changing l_atr to x_att since for non-reservable subs l_atr will be 0
            IF ( v_available_quantity + l_adjustment_quantity < 0 AND l_entry_status_code = 5 )
            AND (l_allow_neg_onhand_prof_val = 2 OR l_neg_inv_rcpt_code =2  )
            THEN
            -- The cycle count adjustment should not be processed since it will
            -- invalidate an existing reservation/allocation.

            -- Reset the approval related colums in the cycle count entry record
            g_cc_entry.approval_type := NULL;
            g_cc_entry.approver_employee_id := NULL;
            g_cc_entry.approval_date := NULL;
            -- Reset the entry status code to 2: Approval required
            -- Do this for both the local variable as well as the global cycle count
            -- entry record
            g_cc_entry.entry_status_code := 2;
            l_entry_status_code := 2;
            END IF;
          END IF;  --Bug 6601010- End of check

            -- Bug number 4469742 moved the IF clause here AS per the discussion WITH the PM
            -- for the complete opinion from the PM please refer to the update in the bug
            --*** JSHERMAN  07/01/05 02:44 pm ***
            -- after this the check IF (v_available_quantity + v_adjustment_quantity < 0)  will happen
             -- irrespective of the the l_neg_inv_rcpt_code flag value

       IF ( l_neg_inv_rcpt_code = 2 ) THEN

        /* Bug 5725198-Added the check for LPN being counted to update quantity tree */
           IF (( l_lpn_id IS NOT NULL ) AND (l_lpn_subinv <> '###' AND l_lpn_locator_id <> -99)) THEN
              inv_quantity_tree_pub.update_quantities ( p_api_version_number => 1.0,
                                                        p_init_msg_lst      => 'F',
                                                        x_return_status     => x_return_status,
                                                        x_msg_count         => l_msg_count,
                                                        x_msg_data          => l_msg_data,
                                                        p_organization_id   => l_org_id,
                                                        p_inventory_item_id => l_item_id,
                                                        p_tree_mode         => 1,
                                                        p_is_revision_control => v_is_rev_controlled,
                                                        p_is_lot_control    => v_is_lot_controlled,
                                                        p_is_serial_control => v_is_ser_controlled,
                                                        p_demand_source_type_id => NULL,
                                                        p_revision          => l_rev,
                                                        p_lot_number        => l_lot_num,
                                                        p_subinventory_code => l_lpn_subinv,
                                                        p_locator_id        => l_lpn_locator_id,
                                                        p_onhand_source     => 3,
                                                        p_containerized     => 0,
                                                        p_primary_quantity  => ABS ( l_adjustment_quantity
                                                                                   ),
                                                        p_secondary_quantity => ABS ( l_sec_adjustment_quantity ), -- nsinghi bug#6052831
                                                        p_quantity_type     => 5,
                                                        x_qoh               => x_qoh,
                                                        x_rqoh              => l_rqoh,
                                                        x_qr                => l_qr,
                                                        x_qs                => l_qs,
                                                        x_att               => x_att,
                                                        x_atr               => l_atr,
                                                        p_lpn_id            => l_lpn_id,
                                                        -- nsinghi bug#6052831 START
                                                        x_sqoh              => l_sqoh,
                                                        x_srqoh             => l_srqoh,
                                                        x_sqr               => l_sqr,
                                                        x_sqs               => l_sqs,
                                                        x_satt              => l_satt,
                                                        x_satr              => l_satr
                                                        -- nsinghi bug#6052831 END
                                                      );
             print_debug ( 'Values after updating quantity tree for LPN ');
             print_debug ( 'x_qoh '|| x_qoh );
             print_debug ( 'l_rqoh '|| l_rqoh );
             print_debug ( 'l_qr '|| l_qr );
             print_debug ( 'l_qs '|| l_qs );
             print_debug ( 'x_att '||x_att );
             print_debug ( 'l_atr '||l_atr );
             print_debug ( 'l_adjustment_quantity '||l_adjustment_quantity );
             print_debug ( 'l_sec_adjustment_quantity '||l_sec_adjustment_quantity ); -- nsinghi bug#6052831
           ELSE
/*
        End of Bug 5725198
*/
         inv_quantity_tree_pub.update_quantities ( p_api_version_number => 1.0,
                                                   p_init_msg_lst      => 'F',
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => l_msg_count,
                                                   x_msg_data          => l_msg_data,
                                                   p_organization_id   => l_org_id,
                                                   p_inventory_item_id => l_item_id,
                                                   p_tree_mode         => 1,
                                                   p_is_revision_control => v_is_rev_controlled,
                                                   p_is_lot_control    => v_is_lot_controlled,
                                                   p_is_serial_control => v_is_ser_controlled,
                                                   p_demand_source_type_id => NULL,
                                                   p_revision          => l_rev,
                                                   p_lot_number        => l_lot_num,
                                                   p_subinventory_code => l_sub,
                                                   p_locator_id        => l_locator_id,
                                                   p_onhand_source     => 3,
                                                   p_containerized     => 0,
                                                   p_primary_quantity  => ABS ( l_adjustment_quantity
                                                                              ),
                                                   p_secondary_quantity => ABS ( l_sec_adjustment_quantity ), -- nsinghi bug#6052831
                                                   p_quantity_type     => 5,
                                                   x_qoh               => x_qoh,
                                                   x_rqoh              => l_rqoh,
                                                   x_qr                => l_qr,
                                                   x_qs                => l_qs,
                                                   x_att               => x_att,
                                                   x_atr               => l_atr,
                                                   p_lpn_id            => NULL, --added for lpn reservation
                                                   -- nsinghi bug#6052831 START
                                                   x_sqoh              => l_sqoh,
                                                   x_srqoh             => l_srqoh,
                                                   x_sqr               => l_sqr,
                                                   x_sqs               => l_sqs,
                                                   x_satt              => l_satt,
                                                   x_satr              => l_satr
                                                   -- nsinghi bug#6052831 END
                                                 );
                                                            print_debug ( 'Values after updating quantity tree for loose quantity ');
                /*
             For Bug 5725198
                */
             print_debug ( 'x_qoh '|| x_qoh );
             print_debug ( 'l_rqoh '|| l_rqoh );
             print_debug ( 'l_qr '|| l_qr );
             print_debug ( 'l_qs '|| l_qs );
             print_debug ( 'x_att '||x_att );
             print_debug ( 'l_atr '||l_atr );
             print_debug ( 'l_adjustment_quantity '||l_adjustment_quantity );
             print_debug ( 'l_sec_adjustment_quantity '||l_sec_adjustment_quantity ); -- nsinghi bug#6052831
            END IF; --End of condition for counting for LPNs
           /* End of fix for Bug 5725198 */


      END IF;

      IF ( l_entry_status_code = 5 ) THEN
         g_cc_entry.approval_date := SYSDATE;
         -- Delete the reservation
         -- Bug 3296675, moved the delete reservation call to final_preupdate_logic and perform_serial_adj_txn
         -- since we are checking for availability
         -- delete_reservation ( );
      END IF;

      l_from_uom  := g_cc_entry.count_uom_current;
      l_txn_uom   := l_from_uom;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Entry Status Code: ===> ' || l_entry_status_code );
         print_debug ( 'Adjustment Quantity: => ' || l_adjustment_quantity );
         print_debug ( 'l_lpn_id:'||l_lpn_id);
      END IF;

      IF ( l_lpn_id IS NOT NULL ) THEN

       /* Bug 5725198-Commenting this part since the LPN sub and loc has already been fetched
                    before querying quantity tree */

         -- Check to see if the LPN exists in a discrepant location
/*         SELECT NVL ( subinventory_code, '###' ),
                NVL ( locator_id, -99 )
         INTO   l_lpn_subinv,
                l_lpn_locator_id
         FROM   WMS_LICENSE_PLATE_NUMBERS
         WHERE  lpn_id = l_lpn_id;
*/
         --Bug 4346071 Added debug message
            IF ( l_debug = 1 ) THEN
                 print_debug ( 'l_lpn_subinv: ===> ' || l_lpn_subinv );
                 print_debug ( 'l_lpn_locator_id: => ' || l_lpn_locator_id );
                 print_debug ( 'g_cc_entry.subinventory:'||g_cc_entry.subinventory);
                print_debug ( 'g_cc_entry.locator_id:'||g_cc_entry.locator_id);
            END IF;
            --End of fix for Bug 4346071

        /*
                End of commented code for Bug 5725198
        */

         --Bug 4346071- Added the check for the valus of sub and locator selected from wlpn.
         IF   l_lpn_subinv <> '###' AND l_lpn_locator_id <> -99  THEN

          IF ( (   l_lpn_subinv <> g_cc_entry.subinventory
                OR l_lpn_locator_id <> g_cc_entry.locator_id
               ) AND (g_condition = FALSE)   -- Bug 4495880- Added the check for g_condition also
             ) THEN
            l_lpn_discrepancy_flag := 1;
          ELSE
            l_lpn_discrepancy_flag := 0;
          END IF;
         END IF; --End of fox for Bug 4346071
      END IF;
      IF ( l_debug = 1 ) THEN
         print_debug ( 'l_lpn_discrepancy_flag:'||l_lpn_discrepancy_flag);
      END IF;

      -- Insert into MMTT if the count entry has been completed and
      -- either an adjustment needs to be made, or an LPN discrepancy
      -- exists in which case we'll need to insert a subinventory transfer
      -- record into MMTT
      IF (     l_entry_status_code = 5
           AND (    l_adjustment_quantity <> 0
                 OR l_lpn_discrepancy_flag = 1 )
         ) THEN

         IF ( l_txn_header_id = -2 ) THEN
            SELECT mtl_material_transactions_s.NEXTVAL
            INTO   l_txn_header_id
            FROM   DUAL;

            g_txn_header_id := l_txn_header_id;
            print_debug ( 'l_txn_header_id '||l_txn_header_id );
         END IF;
         IF ( l_debug = 1 ) THEN
             print_debug ( 'l_txn_header_id '||l_txn_header_id );
             print_debug ( 'l_serial_number :'||l_serial_number);
         END IF;

         IF ( l_serial_number IS NOT NULL ) THEN
            print_debug ( 'l_serial_number '||l_serial_number);
            SELECT mtl_material_transactions_s.NEXTVAL
            INTO   l_txn_temp_id
            FROM   DUAL;

            SELECT auto_serial_alpha_prefix
            INTO   l_serial_prefix
            FROM   mtl_system_items
            WHERE  inventory_item_id = l_item_id
                   AND organization_id = l_org_id;
         END IF;

         l_p_uom_qty :=
            inv_convert.inv_um_convert ( l_item_id,
                                         5,
                                         l_txn_quantity,
                                         l_from_uom,
                                         l_to_uom,
                                         NULL,
                                         NULL
                                       );
         l_txn_ref   := g_cc_entry.reference_current;





         -- This loop is for non multiple serial counts for a serial
         -- controlled item entry where the serial was found in a
         -- discrepant location.  For multiple serials, this logic is
         -- taken care of already in the procedure perform_serial_adj_txn
         -- The serial number field is always null in the cycle count entries
         -- record for multiple serial count option

         IF ( l_serial_number IS NOT NULL ) THEN
            -- Check to see if the serial number is found
            -- in a discrepant location or not
            SELECT NVL ( REVISION, 'XXX' ),
                   NVL ( LOT_NUMBER, 'X' ),
                   CURRENT_STATUS,
                   CURRENT_SUBINVENTORY_CODE,
                   NVL ( CURRENT_LOCATOR_ID, 0 ),
                   NVL ( LPN_ID, -99 )
            INTO   l_msn_revision,
                   l_msn_lot_number,
                   l_current_status,
                   l_msn_subinv,
                   l_msn_locator_id,
                   l_msn_lpn_id
            FROM   MTL_SERIAL_NUMBERS
            WHERE  SERIAL_NUMBER = l_serial_number
            AND    INVENTORY_ITEM_ID = g_cc_entry.inventory_item_id
            AND    CURRENT_ORGANIZATION_ID = g_cc_entry.organization_id;

            -- If serial number exist with status 3 but at a different loc or revision etc.
            -- than we first need to issue out the original serial number and then process
            -- the receipt transaction.  Additionally, if the serial is found
            -- in a different LPN than what is in the system, it will also
            -- issue out the serial first before receiving it back into inventory
            IF (     l_current_status = 3
                 AND l_adjustment_quantity = 1
                 AND (    l_msn_lpn_id <> NVL ( g_cc_entry.parent_lpn_id, -99 )
                       OR (      (    l_msn_revision <> g_cc_entry.revision
                                   OR l_msn_lot_number <>
                                                         g_cc_entry.lot_number
                                   OR l_msn_subinv <> g_cc_entry.subinventory
                                   OR l_msn_locator_id <>
                                                         g_cc_entry.locator_id
                                 )
                            AND l_msn_lpn_id = -99
                            AND g_cc_entry.parent_lpn_id IS NULL
                          )
                     )
               ) THEN

               IF ( l_msn_revision = 'XXX' ) THEN
                  l_msn_revision := NULL;
               END IF;

               IF ( l_msn_lot_number = 'X' ) THEN
                  l_msn_lot_number := NULL;
               END IF;

               IF ( l_msn_locator_id = 0 ) THEN
                  l_msn_locator_id := NULL;
               END IF;

               IF ( l_msn_lpn_id = -99 ) THEN
                  l_msn_lpn_id := NULL;
               END IF;

               l_adj_qty   := -1;

               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Serial discrepancy exists so issue out the serial first'
                              );
                  print_debug ( 'Calling cc_transact with the following parameters: '
                              );
                  print_debug ( 'org_id: ========> ' || l_org_id );
                  print_debug ( 'cc_header_id: ==> ' || l_cc_header_id );
                  print_debug ( 'item_id: =======> ' || l_item_id );
                  print_debug ( 'sub: ===========> ' || l_msn_subinv );
                  print_debug ( 'puomqty: =======> ' || -l_p_uom_qty );
                  print_debug ( 'txnqty: ========> ' || l_adj_qty );
                  print_debug ( 'txnuom: ========> ' || l_txn_uom );
                  print_debug ( 'txndate: =======> ' || l_txn_date );
                  print_debug ( 'txnacctid: =====> ' || l_txn_acct_id );
                  print_debug ( 'lotnum: ========> ' || l_msn_lot_number );
                  print_debug ( 'lotexpdate: ====> ' || l_lot_exp_date );
                  print_debug ( 'rev: ===========> ' || l_msn_revision );
                  print_debug ( 'locator_id: ====> ' || l_msn_locator_id );
                  print_debug ( 'txnref: ========> ' || l_txn_ref );
                  print_debug ( 'reasonid: ======> ' || l_reason_id );
                  print_debug ( 'userid: ========> ' || l_user_id );
                  print_debug ( 'cc_entry_id: ===> ' || l_cycle_count_entry_id );
                  print_debug ( 'loginid: =======> ' || l_login_id );
                  print_debug ( 'txnprocmode: ===> ' || l_txn_proc_mode );
                  print_debug ( 'txnheaderid: ===> ' || l_txn_header_id );
                  print_debug ( 'serialnum: =====> ' || l_serial_number );
                  print_debug ( 'txntempid: =====> ' || l_txn_temp_id );
                  print_debug ( 'serialprefix: ==> ' || l_serial_prefix );
                  print_debug ( 'lpn_id: ========> ' || l_msn_lpn_id );
                  print_debug ( 'cost_group_id: => ' || l_cost_group_id );
                  print_debug ( ' ' );
               END IF;

               l_success_flag :=
                  mtl_cc_transact_pkg.cc_transact ( org_id              => l_org_id,
                                                    cc_header_id        => l_cc_header_id,
                                                    item_id             => l_item_id,
                                                    sub                 => l_msn_subinv,
                                                    puomqty             => -l_p_uom_qty,
                                                    txnqty              => l_adj_qty,
                                                    txnuom              => l_txn_uom,
                                                    txndate             => l_txn_date,
                                                    txnacctid           => l_txn_acct_id,
                                                    lotnum              => l_msn_lot_number,
                                                    lotexpdate          => l_lot_exp_date,
                                                    rev                 => l_msn_revision,
                                                    locator_id          => l_msn_locator_id,
                                                    txnref              => l_txn_ref,
                                                    reasonid            => l_reason_id,
                                                    userid              => l_user_id,
                                                    cc_entry_id         => l_cycle_count_entry_id,
                                                    loginid             => l_login_id,
                                                    txnprocmode         => l_txn_proc_mode,
                                                    txnheaderid         => l_txn_header_id,
                                                    serialnum           => l_serial_number,
                                                    txntempid           => l_txn_temp_id,
                                                    serialprefix        => l_serial_prefix,
                                                    lpn_id              => l_msn_lpn_id,
                                                    cost_group_id       => l_cost_group_id
                                                  );

               IF ( l_debug = 1 ) THEN
                  print_debug ( 'success flag: ' || l_success_flag );
               END IF;

               --If success flag is 2 or 3 then set the message for invalid
               --material status for the lot/serial and the item combination
               IF ( NVL ( l_success_flag, -1 ) < 0 ) THEN
                  FND_MESSAGE.SET_NAME ( 'INV', 'INV_ADJ_TXN_FAILED' );
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF NVL ( l_success_flag, -1 ) = 2 THEN
                  FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_LOT_NA_DUE_MS' );
                  FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_msn_lot_number );
                  FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF NVL ( l_success_flag, -1 ) = 3 THEN
                  FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_SER_NA_DUE_MS' );
                  FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_serial_number );
                  FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               -- Get a new txn temp ID for receiving the serial back into inventory
               SELECT mtl_material_transactions_s.NEXTVAL
               INTO   l_txn_temp_id
               FROM   DUAL;
            END IF;
         END IF;

         -- This loop deals with processing LPN discrepancies and issuing
         -- a sub xfer for the LPN from where it should be on the system to
         -- where the LPN was found on the system
         IF ( l_debug = 1 ) THEN
          print_debug ( 'l_lpn_id:'||l_lpn_id);
         END IF;
         IF ( l_lpn_id IS NOT NULL ) THEN
            -- Check to see if the LPN exists in a discrepant location
            SELECT NVL ( subinventory_code, '###' ),
                   NVL ( locator_id, -99 )
            INTO   l_lpn_subinv,
                   l_lpn_locator_id
            FROM   WMS_LICENSE_PLATE_NUMBERS
            WHERE  lpn_id = l_lpn_id;

            IF ( l_debug = 1 ) THEN
                 print_debug ( 'l_lpn_subinv: ===> ' || l_lpn_subinv );
                 print_debug ( 'l_lpn_locator_id: => ' || l_lpn_locator_id );
                 print_debug ( 'g_cc_entry.subinventory:'||g_cc_entry.subinventory);
                print_debug ( 'g_cc_entry.locator_id:'||g_cc_entry.locator_id);
            END IF;


            --Bug4958692.sub and loc are missing in LPN.So no need of doing sub transfer.
             IF l_lpn_subinv <> '###' AND l_lpn_locator_id <> -99  THEN

            -- If the LPN is found in a different location, then we will
            -- need to do an LPN subinventory transfer first
            IF (    l_lpn_subinv <> g_cc_entry.subinventory
                 OR l_lpn_locator_id <> g_cc_entry.locator_id
               ) THEN
               IF ( l_lpn_subinv = '###' ) THEN
                  l_lpn_subinv := NULL;
               END IF;

               IF ( l_lpn_locator_id = -99 ) THEN
                  l_lpn_locator_id := NULL;
               END IF;


               -- Check to see if a sub transfer record has already been
               -- inserted into MMTT for this LPN so that we only do this once
               SELECT COUNT ( * )
               INTO   l_temp_lpn_count
               FROM   mtl_material_transactions_temp
               WHERE  transaction_header_id = l_txn_header_id
               AND    inventory_item_id = -1
               AND    content_lpn_id = l_lpn_id
               AND    transaction_source_id = l_cc_header_id
               AND    cycle_count_id IS NULL;

               IF ( l_debug = 1 ) THEN
                  print_debug ( 'l_temp_lpn_count:'||l_temp_lpn_count);
               END IF;

               IF ( l_temp_lpn_count <> 0 ) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'The LPN sub xfer record has already been inserted into MMTT'
                                 );
                  END IF;
               ELSE
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'LPN discrepancy exists so transfer the LPN first'
                                 );
                     print_debug ( 'Calling cc_transact with the following parameters: '
                                 );
                     print_debug ( 'org_id: ==========> ' || l_org_id );
                     print_debug ( 'cc_header_id: ====> ' || l_cc_header_id );
                     print_debug ( 'item_id: =========> ' || -1 );
                     print_debug ( 'sub: =============> ' || l_lpn_subinv );
                     print_debug ( 'puomqty: =========> ' || 1 );
                     print_debug ( 'txnqty: ==========> ' || 1 );
                     print_debug ( 'txnuom: ==========> ' || 'Ea' );
                     print_debug ( 'txndate: =========> ' || l_txn_date );
                     print_debug ( 'txnacctid: =======> ' || l_txn_acct_id );
                     print_debug ( 'lotnum: ==========> ' || NULL );
                     print_debug ( 'lotexpdate: ======> ' || NULL );
                     print_debug ( 'rev: =============> ' || NULL );
                     print_debug ( 'locator_id: ======> ' || l_lpn_locator_id );
                     print_debug ( 'txnref: ==========> ' || l_txn_ref );
                     print_debug ( 'reasonid: ========> ' || l_reason_id );
                     print_debug ( 'userid: ==========> ' || l_user_id );
                     print_debug ( 'cc_entry_id: =====> ' || l_cycle_count_entry_id );
                     print_debug ( 'loginid: =========> ' || l_login_id );
                     print_debug ( 'txnprocmode: =====> ' || l_txn_proc_mode );
                     print_debug ( 'txnheaderid: =====> ' || l_txn_header_id );
                     print_debug ( 'serialnum: =======> ' || NULL );
                     print_debug ( 'txntempid: =======> ' || l_txn_temp_id );
                     print_debug ( 'serialprefix: ====> ' || NULL );
                     print_debug ( 'lpn_id: ==========> ' || l_lpn_id );
                     print_debug (    'transfer_sub: ====> '
                                   || g_cc_entry.subinventory
                                 );
                     print_debug (    'transfer_loc_id: => '
                                   || g_cc_entry.locator_id
                                 );
                     print_debug ( 'lpn_discrepancy: => ' || 1 );
                     print_debug ( ' ' );
                  END IF;

                  l_success_flag :=
                     mtl_cc_transact_pkg.cc_transact ( org_id              => l_org_id,
                                                       cc_header_id        => l_cc_header_id,
                                                       item_id             => -1,
                                                       sub                 => l_lpn_subinv,
                                                       PUOMQty             => 1,
                                                       TxnQty              => 1,
                                                       TxnUOM              => 'Ea',
                                                       TxnDate             => l_txn_date,
                                                       TxnAcctId           => l_txn_acct_id,
                                                       LotNum              => NULL,
                                                       LotExpDate          => NULL,
                                                       rev                 => NULL,
                                                       locator_id          => l_lpn_locator_id,
                                                       TxnRef              => l_txn_ref,
                                                       ReasonId            => l_reason_id,
                                                       UserId              => l_user_id,
                                                       cc_entry_id         => l_cycle_count_entry_id,
                                                       LoginId             => l_login_id,
                                                       TxnProcMode         => l_txn_proc_mode,
                                                       TxnHeaderId         => l_txn_header_id,
                                                       SerialNum           => NULL,
                                                       TxnTempId           => l_txn_temp_id,
                                                       SerialPrefix        => NULL,
                                                       Lpn_Id              => l_lpn_id,
                                                       transfer_sub        => g_cc_entry.subinventory,
                                                       transfer_loc_id     => g_cc_entry.locator_id,
                                                       lpn_discrepancy     => 1
                                                     );

                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'success_flag: ' || l_success_flag );
                  END IF;

                  IF ( NVL ( l_success_flag, -1 ) < 0 ) THEN
                     FND_MESSAGE.SET_NAME ( 'INV', 'INV_ADJ_TXN_FAILED' );
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  -- Get a new txn temp ID for the next record into MMTT
                  SELECT mtl_material_transactions_s.NEXTVAL
                  INTO   l_txn_temp_id
                  FROM   DUAL;
               END IF;
            END IF;
            END IF; --End of fix for bug#4958692
            END IF;

         -- Note, since the procedure  system_quantity doesn't consider the sub
         -- or loc when finding the quantity for items packed in an LPN, if
         -- the LPN is discrepant, a sub transfer for the LPN will be issued.
         -- Thus we can still safely insert into MMTT below since the
         -- adjustment was calculated based on what was packed in the LPN and
         -- didn't take into account the sub or the loc.


         IF (     l_txn_quantity <> 0
              AND (    l_serial_count_option <> 3
                    OR l_serial_number_ctrl_code IN ( 1, 6 )
                  )
            ) THEN

            -- Insert into MMTT only if an adjustment needs to be made.
            -- Do not enter this loop if this was called from a multiple
            -- serial count with a serial controlled item that had an LPN
            -- discrepancy and needs a sub xfer to be processed for the LPN.
            -- The outer loop could have been entered if there was no adjustment
            -- to be made but there was an LPN discrepancy and a sub transfer
            -- record had to be inserted into MMTT

            IF ( l_debug = 1 ) THEN
               print_debug ( 'Calling cc_transact with the following parameters: '
                           );
               print_debug ( 'org_id: ========> ' || l_org_id );
               print_debug ( 'cc_header_id: ==> ' || l_cc_header_id );
               print_debug ( 'item_id: =======> ' || l_item_id );
               print_debug ( 'sub: ===========> ' || l_sub );
               print_debug ( 'puomqty: =======> ' || l_p_uom_qty );
               print_debug ( 'txnqty: ========> ' || l_txn_quantity );
               print_debug ( 'txnuom: ========> ' || l_txn_uom );
               print_debug ( 'txndate: =======> ' || l_txn_date );
               print_debug ( 'txnacctid: =====> ' || l_txn_acct_id );
               print_debug ( 'lotnum: ========> ' || l_lot_num );
               print_debug ( 'lotexpdate: ====> ' || l_lot_exp_date );
               print_debug ( 'rev: ===========> ' || l_rev );
               print_debug ( 'locator_id: ====> ' || l_locator_id );
               print_debug ( 'txnref: ========> ' || l_txn_ref );
               print_debug ( 'reasonid: ======> ' || l_reason_id );
               print_debug ( 'userid: ========> ' || l_user_id );
               print_debug ( 'cc_entry_id: ===> ' || l_cycle_count_entry_id );
               print_debug ( 'loginid: =======> ' || l_login_id );
               print_debug ( 'txnprocmode: ===> ' || l_txn_proc_mode );
               print_debug ( 'txnheaderid: ===> ' || l_txn_header_id );
               print_debug ( 'serialnum: =====> ' || l_serial_number );
               print_debug ( 'txntempid: =====> ' || l_txn_temp_id );
               print_debug ( 'serialprefix: ==> ' || l_serial_prefix );
               print_debug ( 'lpn_id: ========> ' || l_lpn_id );
               print_debug ( 'cost_group_id: => ' || l_cost_group_id );
	       print_debug ( 'l_sec_uom:  ====> ' || l_sec_uom );
               print_debug ( 'l_sec_txn_quantity: => ' || l_sec_txn_quantity );
               print_debug ( ' ' );
            END IF;

            l_success_flag :=
               mtl_cc_transact_pkg.cc_transact ( org_id              => l_org_id,
                                                 cc_header_id        => l_cc_header_id,
                                                 item_id             => l_item_id,
                                                 sub                 => l_sub,
                                                 puomqty             => l_p_uom_qty,
                                                 txnqty              => l_txn_quantity,
                                                 txnuom              => l_txn_uom,
                                                 txndate             => l_txn_date,
                                                 txnacctid           => l_txn_acct_id,
                                                 lotnum              => l_lot_num,
                                                 lotexpdate          => l_lot_exp_date,
                                                 rev                 => l_rev,
                                                 locator_id          => l_locator_id,
                                                 txnref              => l_txn_ref,
                                                 reasonid            => l_reason_id,
                                                 userid              => l_user_id,
                                                 cc_entry_id         => l_cycle_count_entry_id,
                                                 loginid             => l_login_id,
                                                 txnprocmode         => l_txn_proc_mode,
                                                 txnheaderid         => l_txn_header_id,
                                                 serialnum           => l_serial_number,
                                                 txntempid           => l_txn_temp_id,
                                                 serialprefix        => l_serial_prefix,
                                                 lpn_id              => l_lpn_id,
                                                 cost_group_id       => l_cost_group_id
                                                ,secUOM              => l_sec_uom   -- INVCONV,NSRIVAST
                                                ,secQty              => l_sec_txn_quantity   --Added fro bug 7429124-- INVCONV,NSRIVAST
                                               );

            IF ( l_debug = 1 ) THEN
               print_debug (    'cc_transact API returned a success flag of: '
                             || l_success_flag
                           );
            END IF;

            --If success flag is 2 or 3 then set the message for invalid
            --material status for the lot/serial and the item combination
            IF (     ( NVL ( l_txn_header_id, -1 ) < 0 )
                 OR ( NVL ( l_success_flag, -1 ) < 0 )
               ) THEN
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_ADJ_TXN_FAILED' );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF NVL ( l_success_flag, -1 ) = 2 THEN
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_LOT_NA_DUE_MS' );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_lot_num );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF NVL ( l_success_flag, -1 ) = 3 THEN
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_SER_NA_DUE_MS' );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_serial_number );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         g_cc_entry.adjustment_date := SYSDATE;
         -- Set the commit status flag so that the TM will be called in the
         -- post commit procedure
         g_commit_status_flag := 1;
         g_cc_entry.inventory_adjustment_account := l_txn_acct_id;
      END IF;
   END final_preupdate_logic;

   PROCEDURE delete_reservation
   IS
      l_mtl_reservation_rec INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
                            := INV_CC_RESERVATIONS_PVT.Define_Reserv_Rec_Type;
      l_init_msg_lst VARCHAR2 ( 1 );
      l_error_code NUMBER;
      l_return_status VARCHAR2 ( 1 );
      l_msg_count NUMBER;
      l_msg_data VARCHAR2 ( 240 );
      lmsg      VARCHAR2 ( 2000 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

      l_lpn_subinv VARCHAR2 ( 10 );  --Bug 6401621
      l_lpn_locator_id NUMBER;	--Bug 6401621
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***delete_reservation***' );
      END IF;

      /* Passing input variable */
      /* Delete only cycle count reservation */
      l_mtl_reservation_rec.demand_source_type_id := 9;
      l_mtl_reservation_rec.organization_id := g_cc_entry.organization_id;
      l_mtl_reservation_rec.inventory_item_id := g_cc_entry.inventory_item_id;
      l_mtl_reservation_rec.subinventory_code := g_cc_entry.subinventory;
      l_mtl_reservation_rec.revision := g_cc_entry.revision;
      l_mtl_reservation_rec.locator_id := g_cc_entry.locator_id;
      l_mtl_reservation_rec.lot_number := g_cc_entry.lot_number;

      --Start Bug 6401621 commented out the following line
      --l_mtl_reservation_rec.lpn_id := NULL;

       -- Bug 6401621 Cycle Count reservation not getting deleted if reservation is stamped with lpn_id
	IF g_cc_entry.parent_lpn_id IS NOT NULL THEN
		l_mtl_reservation_rec.lpn_id := g_cc_entry.parent_lpn_id;

		 SELECT NVL (subinventory_code, '###' ),
                 NVL (locator_id, -99 )
		 INTO   l_lpn_subinv,
                 l_lpn_locator_id
                 FROM   WMS_LICENSE_PLATE_NUMBERS
                 WHERE  lpn_id = g_cc_entry.parent_lpn_id;

		 IF ( l_debug = 1 ) THEN
		         print_debug ( '***l_lpn_subinv***' || l_lpn_subinv );
			 print_debug ( '***l_lpn_locator_id***' || l_lpn_locator_id);
		 END IF;

		 IF  ( l_lpn_subinv <> '###' AND l_lpn_locator_id <> -99 ) THEN
			 l_mtl_reservation_rec.subinventory_code := l_lpn_subinv;
			 l_mtl_reservation_rec.locator_id := l_lpn_locator_id;
		 END IF;
	ELSE
		l_mtl_reservation_rec.lpn_id := NULL;
	END IF;
	--End Bug 6401621

      -- Delete all the reservations
      IF ( l_debug = 1 ) THEN
         print_debug ( 'Calling Delete_All_Reservation with the following values for the reservation record:'
                     );
         print_debug ( 'demand_source_type_id: => ' || 9 );
         print_debug (    'organization_id: =======> '
                       || g_cc_entry.organization_id
                     );
         print_debug (    'inventory_item_id: =====> '
                       || g_cc_entry.inventory_item_id
                     );
         print_debug ( 'subinventory_code: =====> ' || g_cc_entry.subinventory );
         print_debug ( 'revision: ==============> ' || g_cc_entry.revision );
         print_debug ( 'locator_id: ============> ' || g_cc_entry.locator_id );
         print_debug ( 'lot_number: ============> ' || g_cc_entry.lot_number );
         print_debug ( 'lpn_id: ================> ' || NULL );
      END IF;

      INV_CC_RESERVATIONS_PVT.Delete_All_Reservation ( p_api_version_number => 1.0,
                                                       p_init_msg_lst      => l_init_msg_lst,
                                                       p_mtl_reservation_rec => l_mtl_reservation_rec,
                                                       x_error_code        => l_error_code,
                                                       x_return_status     => l_return_status,
                                                       x_msg_count         => l_msg_count,
                                                       x_msg_data          => l_msg_data
                                                     );

      IF ( l_return_status <> 'S' ) THEN
         FND_MSG_PUB.Count_AND_Get ( p_count             => l_msg_count,
                                     p_data              => l_msg_data
                                   );
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END delete_reservation;

   PROCEDURE duplicate_entries
   IS
      l_count   NUMBER;
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_revision VARCHAR2 ( 3 ) := g_cc_entry.revision;
      l_sub     VARCHAR2 ( 10 ) := g_cc_entry.subinventory;
      l_locator_id NUMBER := g_cc_entry.locator_id;
      l_cost_group_id NUMBER := g_cc_entry.cost_group_id;
      l_lot     VARCHAR2 ( 80 ) := g_cc_entry.lot_number; --Bug 6120140 Increased lot size to 80
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_cc_header_id NUMBER := g_cc_entry.cycle_count_header_id;
      l_cc_serial_number VARCHAR2 ( 30 ) := g_cc_entry.serial_number;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_lpn_id  NUMBER := g_cc_entry.parent_lpn_id;

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***duplicate_entries***' );
      END IF;

      SELECT COUNT ( * )
      INTO   l_count
      FROM   mtl_cycle_count_entries
      WHERE  cycle_count_header_id = l_cc_header_id
      AND    organization_id = l_org_id
      AND    inventory_item_id = l_item_id
      AND    subinventory = l_sub
      AND    entry_status_code IN ( 1, 2, 3 )
      --            AND nvl(export_flag,2) = 2
      AND    (    l_locator_id IS NULL
               OR locator_id = l_locator_id )
      AND    (    l_revision IS NULL
               OR revision = l_revision )
      AND    (    l_lot IS NULL
               OR lot_NUMBER = l_lot )
      AND    (    l_cc_serial_number IS NULL
               OR serial_number = l_cc_serial_number
             )
      AND    (    l_cost_group_id IS NULL
               OR cost_group_id = l_cost_group_id)

       AND    NVL(parent_lpn_id,-1 ) = NVL(l_lpn_id, -1);

      IF ( l_count > 0 ) THEN
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_OPEN_REQUEST_EXISTS' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END duplicate_entries;

   PROCEDURE post_commit
   IS
      l_commit_status_flag NUMBER := g_commit_status_flag;
      l_txn_proc_mode NUMBER := g_txn_proc_mode;
      l_req_id  NUMBER;
      l_txn_header_id NUMBER := g_txn_header_id;
      l_cc_header_id NUMBER := g_cc_entry.cycle_count_header_id;
      l_cc_entry_id NUMBER;
      l_entry_status_code NUMBER;
      l_inventory_item_id NUMBER;
      l_wms_installed BOOLEAN;
      l_return_status VARCHAR2 ( 3000 );
      l_msg_count NUMBER;
      l_msg_data VARCHAR2 ( 3000 );
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_txn_return_status NUMBER;
      l_proc_msg VARCHAR2 ( 3000 );
      l_serial_count_option NUMBER;

      CURSOR serial_control_cc_entry
      IS
         SELECT cycle_count_entry_id,
                entry_status_code,
                inventory_item_id
         FROM   MTL_CYCLE_COUNT_ENTRIES_V
         WHERE  cycle_count_header_id = l_cc_header_id
         --       AND nvl(export_flag,2) = 2
         AND    serial_number_control_code IN ( 2, 5 );

      -- Variables needed for calling the label printing API
      l_label_status VARCHAR2 ( 300 ) := NULL;
      l_business_flow_code NUMBER := 8;
      l_temp_count NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***post_commit***' );
         print_debug ( 'Commit status flag: => ' || g_commit_status_flag );
         print_debug ( 'Txn Process mode: ===> ' || g_txn_proc_mode );
         print_debug ( 'Txn header ID: ======> ' || g_txn_header_id );
         print_debug (    'CC header ID: =======> '
                       || g_cc_entry.cycle_count_header_id
                     );
         print_debug ( 'Organization ID: ====> ' || g_cc_entry.organization_id );
      END IF;

      -- First make sure that if the commit status flag is 1,
      -- that there does indeed exist a record in MMTT for the transaction
      -- manager to process
      IF ( l_commit_status_flag = 1 ) THEN
         SELECT COUNT ( * )
         INTO   l_temp_count
         FROM   mtl_material_transactions_temp
         WHERE  transaction_header_id = l_txn_header_id;

         IF ( l_temp_count = 0 ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'No record exists in MMTT to process so reset the status flag'
                           );
            END IF;

            g_commit_status_flag := 2;
            l_commit_status_flag := 2;
         END IF;
      END IF;

      -- Bug# 2278521
      -- Don't need to unmark the serials anymore since if they were marked,
      -- that means they require an adjustment.  The TM will unmark these
      -- serials when it has finished processing them.

      -- Get the serial count option
      /*SELECT NVL(serial_count_option, 1)
        INTO l_serial_count_option
        FROM mtl_cycle_count_headers
        WHERE cycle_count_header_id = l_cc_header_id
        AND organization_id = l_org_id;

      -- Unmark the serials that were marked previously
      -- since they will be processed here
      OPEN serial_control_cc_entry;
      LOOP
         FETCH serial_control_cc_entry INTO l_cc_entry_id,
      l_entry_status_code, l_inventory_item_id;
         IF (serial_control_cc_entry%NOTFOUND) THEN
       EXIT;
         END IF;
         IF (l_entry_status_code = 5 OR l_entry_status_code = 3) THEN
       IF (l_debug = 1) THEN
          print_debug('Unmarking the serials for cc_entry_id: ' || l_cc_entry_id);
       END IF;
       unmark(l_cc_entry_id);
       -- If the entry is a multiple serial entry,
       -- unmark the serial explicitly here since it was marked
       -- through a different process compared to single serial
       IF (l_serial_count_option = 3) THEN
          UPDATE mtl_serial_numbers
            SET group_mark_id = NULL
            WHERE inventory_item_id = l_inventory_item_id
            AND current_organization_id = l_org_id
            AND serial_number IN
            (SELECT serial_number
             FROM mtl_cc_serial_numbers
             WHERE cycle_count_entry_id = l_cc_entry_id);
       END IF;
         END IF;
      END LOOP;
      CLOSE serial_control_cc_entry;*/
      -- End of Bug# 2278521

      IF NVL ( l_commit_status_flag, 2 ) = 1 THEN
         IF ( l_txn_proc_mode = 1 ) THEN
            /* txn usr exit */

            -- Call the new WMS enabled transaction manager here
            -- Bug# 2328371
            -- Also pass in the business flow code so the TM will
            -- automatically print the labels
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Calling the online TM here: ' || l_txn_header_id
                           );
            END IF;

            l_txn_return_status :=
               INV_LPN_TRX_PUB.PROCESS_LPN_TRX ( p_trx_hdr_id        => l_txn_header_id,
                                                 x_proc_msg          => l_proc_msg,
                                                 p_business_flow_code => l_business_flow_code
                                               );

            -- Check if the Transaction Manager was successful or not
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Txn return status: ' || l_txn_return_status );
            END IF;

            IF ( l_txn_return_status <> 0 ) THEN
               -- This 'Transaction Failed' message is set on the java side
               --FND_MESSAGE.SET_NAME('INV', 'INV_FAILED');
               --FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            FND_MESSAGE.SET_NAME ( 'INV', 'INV_ADJUSTMENTS_PROCESSED' );
            FND_MESSAGE.SET_TOKEN ( 'ENTITY', 'INV_CYCLE_COUNT', TRUE );
            FND_MSG_PUB.ADD;
         /* Call the label printing API. */
         -- Bug# 2328371
         -- Since we are passing in the business flow code to the TM,
         -- we don't need to explicitly call the label printing API anymore
         --print_debug('Calling print_label_wrap with the following input parameters');
         --print_debug('p_business_flow_code: => ' || l_business_flow_code);
         --print_debug('p_transaction_id: =====> ' || l_txn_header_id);

         -- Bug# 2301732
         -- Make the call to the label printing API more robust
         -- by trapping for exceptions when calling it
         /*BEGIN
            inv_label.print_label_wrap
              ( x_return_status        =>  l_return_status        ,
           x_msg_count            =>  l_msg_count            ,
           x_msg_data             =>  l_msg_data             ,
           x_label_status         =>  l_label_status         ,
           p_business_flow_code   =>  l_business_flow_code   ,
           p_transaction_id       =>  l_txn_header_id );
         EXCEPTION
            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                  print_debug('Error while calling label printing API');
               END IF;
               FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LABEL_FAILE');
               FND_MSG_PUB.ADD;
         END;
         IF (l_debug = 1) THEN
              print_debug('After calling label printing API: ' || l_return_status || ', ' || l_label_status || ', ' || l_msg_data);
         END IF;

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LABEL_FAILE');
            FND_MSG_PUB.ADD;
         END IF;*/
         ELSIF ( l_txn_proc_mode = 2 ) THEN
            /* txn process concurrent program */

            -- Call the new WMS enabled transaction manager here
            -- Bug# 2328371
            -- Also pass in the business flow code so the TM will
            -- automatically print the labels
            IF ( l_debug = 1 ) THEN
               print_debug (    'Calling the concurrent TM here: '
                             || l_txn_header_id
                           );
            END IF;

            l_txn_return_status :=
               INV_LPN_TRX_PUB.PROCESS_LPN_TRX ( p_trx_hdr_id        => l_txn_header_id,
                                                 x_proc_msg          => l_proc_msg,
                                                 p_business_flow_code => l_business_flow_code
                                               );

            -- Check if the Transaction Manager was successful or not
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Txn return status: ' || l_txn_return_status );
            END IF;

            IF ( l_txn_return_status <> 0 ) THEN
               -- This 'Transaction Failed' message is set on the java side
               --FND_MESSAGE.SET_NAME('INV', 'INV_FAILED');
               --FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            FND_MESSAGE.SET_NAME ( 'INV', 'INV_CONC_SUBMITTED' );
            FND_MESSAGE.SET_TOKEN ( 'REQUEST_ID', TO_CHAR ( l_req_id ), FALSE );
            FND_MSG_PUB.ADD;
         /* Call the label printing API. */
         -- Bug# 2328371
         -- Since we are passing in the business flow code to the TM,
         -- we don't need to explicitly call the label printing API anymore
         --print_debug('Calling print_label_wrap with the following input parameters');
         --print_debug('p_business_flow_code: => ' || l_business_flow_code);
         --print_debug('p_transaction_id: =====> ' || l_txn_header_id);

         -- Bug# 2301732
         -- Make the call to the label printing API more robust
         -- by trapping for exceptions when calling it
              /*BEGIN
            inv_label.print_label_wrap
              ( x_return_status        =>  l_return_status        ,
           x_msg_count            =>  l_msg_count            ,
           x_msg_data             =>  l_msg_data             ,
           x_label_status         =>  l_label_status         ,
           p_business_flow_code   =>  l_business_flow_code   ,
           p_transaction_id       =>  l_txn_header_id );
         EXCEPTION
            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                  print_debug('Error while calling label printing API');
               END IF;
               FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LABEL_FAILE');
               FND_MSG_PUB.ADD;
         END;
         IF (l_debug = 1) THEN
            print_debug('After calling label printing API: ' || l_return_status || ', ' || l_label_status || ', ' || l_msg_data);
         END IF;

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LABEL_FAILE');
            FND_MSG_PUB.ADD;
         END IF;*/
         ELSE
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_BACKGROUND_PENDING' );
            FND_MSG_PUB.ADD;
         END IF;
      END IF;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Resetting the global values here after calling post_commit'
                     );
      END IF;

      -- Reset the global variables
      g_update_flag := 2;
      g_insert_flag := 2;
      g_commit_status_flag := 2;
      g_txn_header_id := NULL;
     /* Bug 4495880 -Resetting the global paramter to FALSE*/
      g_condition := FALSE;
     /* End of fix for Bug 4495880 */

   END post_commit;

   PROCEDURE system_quantity (
      x_system_quantity OUT NOCOPY NUMBER
   )
   IS
/*
      l_conversion_qty NUMBER := 0;
      l_primary_sys_qty NUMBER := 0;
      l_loaded_sys_qty NUMBER := 0; -- bug 2640378
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_to_uom  VARCHAR2 ( 3 ) := g_count_uom;
      l_from_uom VARCHAR2 ( 3 );
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_sub     VARCHAR2 ( 10 ) := g_cc_entry.subinventory;
      l_lot     VARCHAR2 ( 30 ) := g_cc_entry.lot_number;
      l_rev     VARCHAR2 ( 10 ) := g_cc_entry.revision;
      l_loc     NUMBER := g_cc_entry.locator_id;
      l_cost_group_id NUMBER := g_cc_entry.cost_group_id;
      l_last_updated_by NUMBER := g_cc_entry.last_updated_by;
      l_last_update_login NUMBER := g_cc_entry.last_update_login;
      l_cycle_count_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      l_lpn_id  NUMBER := g_cc_entry.parent_lpn_id;
      l_current_sys_qty NUMBER := 0;
      l_serial_number VARCHAR2 ( 30 ) := g_cc_entry.serial_number;
      x_error_code NUMBER := 0;
      x_return_status VARCHAR2 ( 1 );
      x_init_msg_lst VARCHAR2 ( 1 );
      x_commit  VARCHAR2 ( 1 );
      x_msg_count NUMBER := 0;
      x_msg_data VARCHAR2 ( 240 );
      l_serial_number_control_code NUMBER;
      l_serial_count_option NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      -- Bug 4886188 -Added the local variables for the lpn details from wlpn

       l_lpn_subinv  VARCHAR2(10) ;
       l_lpn_locator_id  NUMBER ;
       l_lpn_context  NUMBER;

      -- End of fix for Bug 4886188
*/
      x_sec_system_quantity NUMBER; -- nsinghi bug#6052831
   BEGIN
-- nsinghi bug#6052831 START. Call the overriden method.
      system_quantity ( x_system_quantity => x_system_quantity
                        , x_sec_system_quantity => x_sec_system_quantity ); -- nsinghi Bug#6052831. Call overloaded API.
/*
      IF ( l_debug = 1 ) THEN
         print_debug ( '***system_quantity***' );
      END IF;



              ******  Fix for bug 4886188
              ******  If the Lpn Context is 'Issued Out of Stores' or 'Intransit' or 'Packing Context' or 'Loaded to Dock'
              ******  system quantity should be shown as 0. Because, ideally the LPN will not be present in that location.


            IF ( l_lpn_id IS NOT NULL ) THEN

               SELECT NVL ( subinventory_code, '###' ),
                      NVL ( locator_id, -99 ),
                      lpn_context
               INTO   l_lpn_subinv,
                      l_lpn_locator_id,
                      l_lpn_context
               FROM   WMS_LICENSE_PLATE_NUMBERS
               WHERE  lpn_id = l_lpn_id ;

               IF ( l_debug = 1 ) THEN
                    print_debug ( 'l_lpn_subinv: ===> ' || l_lpn_subinv );
                    print_debug ( 'l_lpn_locator_id: => ' || l_lpn_locator_id );
                    print_debug ( 'l_lpn_context: => ' || l_lpn_context );
               END IF;

               IF l_lpn_context = 8 or l_lpn_context = 9 or l_lpn_context = 4 or l_lpn_context = 6 THEN
                  IF ( l_debug = 1 ) THEN
                    print_debug ( 'Returning the system quantity as 0' );
                  END IF;
                  x_system_quantity := 0;
                  g_condition:=TRUE ;
                  return;
               END IF;
           END IF;
           --  End of fix for bug number 4886188





      -- Get the required variable values from the fields
      SELECT primary_uom_code,
             serial_number_control_code
      INTO   l_from_uom,
             l_serial_number_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_count_option, 1 )
      INTO   l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Serial count option: ' || l_serial_count_option );
      END IF;

      IF (    l_serial_number_control_code IN ( 1, 6 )
           OR l_serial_count_option = 1
         ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Non serial controlled item' );
         END IF;

         IF l_lpn_id IS NULL THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is null' );
            END IF;

            IF wms_is_installed ( l_org_id ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'WMS is installed' );
               END IF;

               SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
               INTO   l_primary_sys_qty
               FROM   MTL_ONHAND_QUANTITIES_DETAIL
               WHERE  inventory_item_id = l_item_id
               AND    organization_id = l_org_id
               AND    NVL ( containerized_flag, 2 ) = 2
               AND    subinventory_code = l_sub
               AND    NVL ( lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( locator_id, -2 ) = NVL ( l_loc, -2 )
               AND    NVL ( cost_group_id, -9 ) = NVL ( l_cost_group_id, -9 );

               SELECT NVL ( SUM ( quantity ), 0 )
               INTO   l_loaded_sys_qty
               FROM   WMS_LOADED_QUANTITIES_V
               WHERE  inventory_item_id = l_item_id
               AND    organization_id = l_org_id
               AND    NVL ( containerized_flag, 2 ) = 2
               AND    subinventory_code = l_sub
               AND    NVL ( lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( locator_id, -2 ) = NVL ( l_loc, -2 )
               --Bug# 3071372
               --AND    NVL ( cost_group_id, -9 ) = NVL ( l_cost_group_id, -9 )
               AND    qty_type = 'LOADED'
               AND    lpn_id IS NULL
               AND    content_lpn_id IS NULL;                                                       -- bug 2640378
                                              -- need lpn_id and content lpn id is null because there could be a
                                              -- row in wms_loaded_quantities_v which has these fields populated for the
                                              -- same items/sub.. combination and here we are processing loose

               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Loaded qty is ' || l_loaded_sys_qty );
               END IF;

               IF l_loaded_sys_qty > 0 THEN
                  l_primary_sys_qty := l_primary_sys_qty - l_loaded_sys_qty;
               END IF; -- bug 2640378
            ELSE
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'WMS is not installed' );
               END IF;

               SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
               INTO   l_primary_sys_qty
               FROM   MTL_ONHAND_QUANTITIES_DETAIL
               WHERE  inventory_item_id = l_item_id
               AND    organization_id = l_org_id
               AND    NVL ( containerized_flag, 2 ) = 2
               AND    subinventory_code = l_sub
               AND    NVL ( lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( locator_id, -2 ) = NVL ( l_loc, -2 );
            END IF;
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is not null' || l_lpn_id );
            END IF;

            MTL_INV_UTIL_GRP.Get_LPN_Item_SysQty ( p_api_version       => 0.9,
                                                   p_init_msg_lst      => NULL,
                                                   p_commit            => NULL,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data,
                                                   p_organization_id   => l_org_id,
                                                   p_lpn_id            => l_lpn_id,
                                                   p_inventory_item_id => l_item_id,
                                                   p_lot_number        => l_lot,
                                                   p_revision          => l_rev,
                                                   p_serial_number     => l_serial_number,
                                                   p_cost_group_id     => l_cost_group_id,
                                                   x_lpn_systemqty     => l_primary_sys_qty
                                                 );
         END IF;
      ELSIF (     l_serial_number_control_code IN ( 2, 5 )
              AND l_serial_count_option > 1
            ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial controlled item' );
         END IF;

         IF ( l_lpn_id IS NULL ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'No LPN ID' );
            END IF;

            -- Bug# 2386909
            -- Also make sure you query only serials which are loose
            SELECT NVL ( SUM ( DECODE ( msn.current_status, 3, 1, 0 ) ), 0 )
            INTO   l_primary_sys_qty
            FROM   mtl_serial_numbers msn
            WHERE  msn.serial_number = NVL ( l_serial_number, serial_number )
            AND    msn.inventory_item_id = l_item_id
            AND    msn.current_organization_id = l_org_id
            AND    msn.current_subinventory_code = l_sub
            AND    NVL ( msn.lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
            AND    NVL ( msn.revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
            AND    NVL ( msn.current_locator_id, -2 ) = NVL ( l_loc, -2 )
            AND    msn.lpn_id IS NULL
            AND    is_serial_loaded ( l_org_id,
                                      l_item_id,
                                      NVL ( l_serial_number, serial_number ),
                                      NULL
                                    ) = 2;
         -- bug 2640378
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID' || l_lpn_id );
            END IF;

            MTL_INV_UTIL_GRP.Get_LPN_Item_SysQty ( p_api_version       => 0.9,
                                                   p_init_msg_lst      => NULL,
                                                   p_commit            => NULL,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data,
                                                   p_organization_id   => l_org_id,
                                                   p_lpn_id            => l_lpn_id,
                                                   p_inventory_item_id => l_item_id,
                                                   p_lot_number        => l_lot,
                                                   p_revision          => l_rev,
                                                   p_serial_number     => l_serial_number,
                                                   p_cost_group_id     => l_cost_group_id,
                                                   x_lpn_systemqty     => l_primary_sys_qty
                                                 );
         END IF;

         IF ( l_serial_count_option = 3 ) THEN
            IF ( l_cycle_count_entry_id IS NULL ) THEN
               SELECT mtl_cycle_count_entries_s.NEXTVAL
               INTO   l_cycle_count_entry_id
               FROM   DUAL;

               g_cc_entry.cycle_count_entry_id := l_cycle_count_entry_id;
            END IF;

            -- Every time you calculate system quantity make sure that we update
            -- MTL_CC_SERIAL_NUMBERS table. So that change in system quantity is reflected
            -- in SERIAL_NUMBERS also
            -- Bug# 2386909
            -- Match against the LPN ID also when performing this insert statement
            INSERT INTO MTL_CC_SERIAL_NUMBERS
                        ( CYCLE_COUNT_ENTRY_ID,
                          SERIAL_NUMBER,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_LOGIN
                        )
               SELECT l_cycle_count_entry_id,
                      SERIAL_NUMBER,
                      SYSDATE,
                      l_last_updated_by,
                      SYSDATE,
                      l_last_updated_by,
                      l_last_update_login
               FROM   mtl_serial_numbers msn
               WHERE  msn.inventory_item_id = l_item_id
               AND    msn.current_organization_id = l_org_id
               AND    msn.current_subinventory_code = l_sub
               AND    NVL ( msn.lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( msn.revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( msn.current_locator_id, -2 ) = NVL ( l_loc, -2 )
               AND    msn.current_status = 3
               AND    NVL ( msn.lpn_id, -99999 ) = NVL ( l_lpn_id, -99999 )
               AND    NOT EXISTS (
                         SELECT 'x'
                         FROM   MTL_CC_SERIAL_NUMBERS
                         WHERE  CYCLE_COUNT_ENTRY_ID = l_cycle_count_entry_id
                         AND    SERIAL_NUMBER = msn.SERIAL_NUMBER );
         END IF;
      END IF;

      IF ( l_primary_sys_qty IS NULL ) THEN
         l_primary_sys_qty := 0;
      END IF;

      IF (( l_serial_count_option <> 3) OR
         ( l_serial_count_option = 3 AND l_serial_number_control_code IN (1, 6) ) )
      THEN
         l_conversion_qty :=
            inv_convert.inv_um_convert ( l_item_id,
                                         5,
                                         l_primary_sys_qty,
                                         l_from_uom,
                                         l_to_uom,
                                         NULL,
                                         NULL
                                       );
      ELSE
         -- Don't need to convert the quantity for multiple
         -- serial count option since the serials will be counted
         -- in the item's primary UOM code
         l_conversion_qty := l_primary_sys_qty;
      END IF;

      -- Set the output variable equal to the final converted system quantity
      x_system_quantity := l_conversion_qty;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Quantity returned: ' || x_system_quantity );
      END IF;
*/
   END system_quantity;

-- nsinghi bug#6052831. Created overloaded procedure to handle secondary qty.
   PROCEDURE system_quantity (
      x_system_quantity OUT NOCOPY NUMBER
      , x_sec_system_quantity OUT NOCOPY NUMBER
   )
   IS
      l_conversion_qty NUMBER := 0;
      l_primary_sys_qty NUMBER := 0;
      l_secondary_sys_qty NUMBER := 0; -- nsinghi bug#6052831
      l_loaded_sec_sys_qty NUMBER := 0; -- nsinghi bug#6052831
      l_loaded_sys_qty NUMBER := 0; -- bug 2640378
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_to_uom  VARCHAR2 ( 3 ) := g_count_uom;
      l_from_uom VARCHAR2 ( 3 );
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_sub     VARCHAR2 ( 10 ) := g_cc_entry.subinventory;
      l_lot     VARCHAR2 ( 80 ) := g_cc_entry.lot_number;--Bug 6120140 Increased lot size to 80
      l_rev     VARCHAR2 ( 10 ) := g_cc_entry.revision;
      l_loc     NUMBER := g_cc_entry.locator_id;
      l_cost_group_id NUMBER := g_cc_entry.cost_group_id;
      l_last_updated_by NUMBER := g_cc_entry.last_updated_by;
      l_last_update_login NUMBER := g_cc_entry.last_update_login;
      l_cycle_count_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      l_lpn_id  NUMBER := g_cc_entry.parent_lpn_id;
      l_current_sys_qty NUMBER := 0;
      l_serial_number VARCHAR2 ( 30 ) := g_cc_entry.serial_number;
      x_error_code NUMBER := 0;
      x_return_status VARCHAR2 ( 1 );
      x_init_msg_lst VARCHAR2 ( 1 );
      x_commit  VARCHAR2 ( 1 );
      x_msg_count NUMBER := 0;
      x_msg_data VARCHAR2 ( 240 );
      l_serial_number_control_code NUMBER;
      l_serial_count_option NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      /* Bug 4886188 -Added the local variables for the lpn details from wlpn*/

       l_lpn_subinv  VARCHAR2(10) ;
       l_lpn_locator_id  NUMBER ;
       l_lpn_context  NUMBER;

      /* End of fix for Bug 4886188 */
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***system_quantity***' );
      END IF;


          /*
              ******  Fix for bug 4886188
              ******  If the Lpn Context is 'Issued Out of Stores' or 'Intransit' or 'Packing Context' or 'Loaded to Dock'
              ******  system quantity should be shown as 0. Because, ideally the LPN will not be present in that location.
           */

            IF ( l_lpn_id IS NOT NULL ) THEN

               SELECT NVL ( subinventory_code, '###' ),
                      NVL ( locator_id, -99 ),
                      lpn_context
               INTO   l_lpn_subinv,
                      l_lpn_locator_id,
                      l_lpn_context
               FROM   WMS_LICENSE_PLATE_NUMBERS
               WHERE  lpn_id = l_lpn_id ;

               IF ( l_debug = 1 ) THEN
                    print_debug ( 'l_lpn_subinv: ===> ' || l_lpn_subinv );
                    print_debug ( 'l_lpn_locator_id: => ' || l_lpn_locator_id );
                    print_debug ( 'l_lpn_context: => ' || l_lpn_context );
               END IF;

               IF l_lpn_context = 8 or l_lpn_context = 9 or l_lpn_context = 4 or l_lpn_context = 6 THEN
                  IF ( l_debug = 1 ) THEN
                    print_debug ( 'Returning the system quantity as 0' );
                  END IF;
                  x_system_quantity := 0;
                  g_condition:=TRUE ;
                  return;
               END IF;
           END IF;
           /*  End of fix for bug number 4886188 */





      -- Get the required variable values from the fields
      SELECT primary_uom_code,
             serial_number_control_code
      INTO   l_from_uom,
             l_serial_number_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_count_option, 1 )
      INTO   l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Serial count option: ' || l_serial_count_option );
      END IF;

      IF (    l_serial_number_control_code IN ( 1, 6 )
           OR l_serial_count_option = 1
         ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Non serial controlled item' );
         END IF;

         IF l_lpn_id IS NULL THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is null' );
            END IF;

            IF wms_is_installed ( l_org_id ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'WMS is installed' );
               END IF;

               SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
                      , NVL ( SUM ( secondary_transaction_quantity ), 0 ) -- nsinghi bug#6052831
               INTO   l_primary_sys_qty
                      , l_secondary_sys_qty  -- nsinghi bug#6052831
               FROM   MTL_ONHAND_QUANTITIES_DETAIL
               WHERE  inventory_item_id = l_item_id
               AND    organization_id = l_org_id
               AND    NVL ( containerized_flag, 2 ) = 2
               AND    subinventory_code = l_sub
               AND    NVL ( lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( locator_id, -2 ) = NVL ( l_loc, -2 )
               AND    NVL ( cost_group_id, -9 ) = NVL ( l_cost_group_id, -9 );

               SELECT NVL ( SUM ( quantity ), 0 )
                      , NVL ( SUM ( secondary_quantity ), 0 ) -- nsinghi bug#6052831
               INTO   l_loaded_sys_qty
                      , l_loaded_sec_sys_qty -- nsinghi bug#6052831
               FROM   WMS_LOADED_QUANTITIES_V
               WHERE  inventory_item_id = l_item_id
               AND    organization_id = l_org_id
               AND    NVL ( containerized_flag, 2 ) = 2
               AND    subinventory_code = l_sub
               AND    NVL ( lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( locator_id, -2 ) = NVL ( l_loc, -2 )
               --Bug# 3071372
               --AND    NVL ( cost_group_id, -9 ) = NVL ( l_cost_group_id, -9 )
               AND    qty_type = 'LOADED'
               AND    lpn_id IS NULL
               AND    content_lpn_id IS NULL;                                                       -- bug 2640378
                                              -- need lpn_id and content lpn id is null because there could be a
                                              -- row in wms_loaded_quantities_v which has these fields populated for the
                                              -- same items/sub.. combination and here we are processing loose

               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Loaded qty is ' || l_loaded_sys_qty );
               END IF;

               IF l_loaded_sys_qty > 0 THEN
                  l_primary_sys_qty := l_primary_sys_qty - l_loaded_sys_qty;
               END IF; -- bug 2640378
            ELSE
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'WMS is not installed' );
               END IF;

               SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
                      , NVL ( SUM ( secondary_transaction_quantity ), 0 ) -- nsinghi bug#6052831
               INTO   l_primary_sys_qty
                      , l_secondary_sys_qty  -- nsinghi bug#6052831
               FROM   MTL_ONHAND_QUANTITIES_DETAIL
               WHERE  inventory_item_id = l_item_id
               AND    organization_id = l_org_id
               AND    NVL ( containerized_flag, 2 ) = 2
               AND    subinventory_code = l_sub
               AND    NVL ( lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( locator_id, -2 ) = NVL ( l_loc, -2 );
            END IF;
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is not null' || l_lpn_id );
            END IF;

            MTL_INV_UTIL_GRP.Get_LPN_Item_SysQty ( p_api_version       => 0.9,
                                                   p_init_msg_lst      => NULL,
                                                   p_commit            => NULL,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data,
                                                   p_organization_id   => l_org_id,
                                                   p_lpn_id            => l_lpn_id,
                                                   p_inventory_item_id => l_item_id,
                                                   p_lot_number        => l_lot,
                                                   p_revision          => l_rev,
                                                   p_serial_number     => l_serial_number,
                                                   p_cost_group_id     => l_cost_group_id,
                                                   x_lpn_systemqty     => l_primary_sys_qty,
                                                   x_lpn_sec_systemqty => l_secondary_sys_qty -- nsinghi bug#6052831
                                                 );
         END IF;
      ELSIF (     l_serial_number_control_code IN ( 2, 5 )
              AND l_serial_count_option > 1
            ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial controlled item' );
         END IF;

         IF ( l_lpn_id IS NULL ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'No LPN ID' );
            END IF;

            -- Bug# 2386909
            -- Also make sure you query only serials which are loose
            SELECT NVL ( SUM ( DECODE ( msn.current_status, 3, 1, 0 ) ), 0 )
            INTO   l_primary_sys_qty
            FROM   mtl_serial_numbers msn
            WHERE  msn.serial_number = NVL ( l_serial_number, serial_number )
            AND    msn.inventory_item_id = l_item_id
            AND    msn.current_organization_id = l_org_id
            AND    msn.current_subinventory_code = l_sub
            AND    NVL ( msn.lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
            AND    NVL ( msn.revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
            AND    NVL ( msn.current_locator_id, -2 ) = NVL ( l_loc, -2 )
            AND    msn.lpn_id IS NULL
            AND    is_serial_loaded ( l_org_id,
                                      l_item_id,
                                      NVL ( l_serial_number, serial_number ),
                                      NULL
                                    ) = 2;
         -- bug 2640378
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID' || l_lpn_id );
            END IF;

            MTL_INV_UTIL_GRP.Get_LPN_Item_SysQty ( p_api_version       => 0.9,
                                                   p_init_msg_lst      => NULL,
                                                   p_commit            => NULL,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data,
                                                   p_organization_id   => l_org_id,
                                                   p_lpn_id            => l_lpn_id,
                                                   p_inventory_item_id => l_item_id,
                                                   p_lot_number        => l_lot,
                                                   p_revision          => l_rev,
                                                   p_serial_number     => l_serial_number,
                                                   p_cost_group_id     => l_cost_group_id,
                                                   x_lpn_systemqty     => l_primary_sys_qty
                                                 );
         END IF;

         IF ( l_serial_count_option = 3 ) THEN
            IF ( l_cycle_count_entry_id IS NULL ) THEN
               SELECT mtl_cycle_count_entries_s.NEXTVAL
               INTO   l_cycle_count_entry_id
               FROM   DUAL;

               g_cc_entry.cycle_count_entry_id := l_cycle_count_entry_id;
            END IF;

            -- Every time you calculate system quantity make sure that we update
            -- MTL_CC_SERIAL_NUMBERS table. So that change in system quantity is reflected
            -- in SERIAL_NUMBERS also
            -- Bug# 2386909
            -- Match against the LPN ID also when performing this insert statement
            INSERT INTO MTL_CC_SERIAL_NUMBERS
                        ( CYCLE_COUNT_ENTRY_ID,
                          SERIAL_NUMBER,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_LOGIN
                        )
               SELECT l_cycle_count_entry_id,
                      SERIAL_NUMBER,
                      SYSDATE,
                      l_last_updated_by,
                      SYSDATE,
                      l_last_updated_by,
                      l_last_update_login
               FROM   mtl_serial_numbers msn
               WHERE  msn.inventory_item_id = l_item_id
               AND    msn.current_organization_id = l_org_id
               AND    msn.current_subinventory_code = l_sub
               AND    NVL ( msn.lot_number, 'XX' ) = NVL ( l_lot, 'XX' )
               AND    NVL ( msn.revision, 'XXX' ) = NVL ( l_rev, 'XXX' )
               AND    NVL ( msn.current_locator_id, -2 ) = NVL ( l_loc, -2 )
               AND    msn.current_status = 3
               AND    NVL ( msn.lpn_id, -99999 ) = NVL ( l_lpn_id, -99999 )
               AND    NOT EXISTS (
                         SELECT 'x'
                         FROM   MTL_CC_SERIAL_NUMBERS
                         WHERE  CYCLE_COUNT_ENTRY_ID = l_cycle_count_entry_id
                         AND    SERIAL_NUMBER = msn.SERIAL_NUMBER );
         END IF;
      END IF;

      IF ( l_primary_sys_qty IS NULL ) THEN
         l_primary_sys_qty := 0;
      END IF;
      -- nsinghi bug#6052831 START
      IF ( l_secondary_sys_qty IS NULL ) THEN
         l_secondary_sys_qty := 0;
      END IF;
      -- nsinghi bug#6052831 END

      IF (( l_serial_count_option <> 3) OR
         ( l_serial_count_option = 3 AND l_serial_number_control_code IN (1, 6) ) )
      THEN
         l_conversion_qty :=
            inv_convert.inv_um_convert ( l_item_id,
                                         5,
                                         l_primary_sys_qty,
                                         l_from_uom,
                                         l_to_uom,
                                         NULL,
                                         NULL
                                       );
      ELSE
         -- Don't need to convert the quantity for multiple
         -- serial count option since the serials will be counted
         -- in the item's primary UOM code
         l_conversion_qty := l_primary_sys_qty;
      END IF;

      -- Set the output variable equal to the final converted system quantity
      x_system_quantity := l_conversion_qty;
      x_sec_system_quantity := l_secondary_sys_qty; -- nsinghi bug#6052831

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Quantity returned: ' || x_system_quantity );
         print_debug ( 'Secondary Quantity returned: ' || x_sec_system_quantity );
      END IF;
   END system_quantity;

   PROCEDURE value_variance (
      x_value_variance OUT NOCOPY NUMBER
   )
   IS
      l_count_qty NUMBER := g_count_quantity;
      l_system_qty NUMBER;
      l_item_cost NUMBER;
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_value_variance NUMBER;
      l_conversion_qty NUMBER;
      l_from_uom VARCHAR2 ( 3 ) := g_count_uom;
      l_to_uom  VARCHAR2 ( 3 );
      l_adj_qty NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***value_variance***' );
      END IF;

      -- Get the item system quantity
      system_quantity ( x_system_quantity => l_system_qty );
      -- Get the item cost
      l_item_cost :=
         get_item_cost ( in_org_id           => g_cc_entry.organization_id,
                         in_item_id          => g_cc_entry.inventory_item_id,
                         in_locator_id       => g_cc_entry.locator_id
                       );
      g_cc_entry.item_unit_cost := l_item_cost;

      -- Get the item primary uom code
      SELECT primary_uom_code
      INTO   l_to_uom
      FROM   MTL_SYSTEM_ITEMS
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Convert the system quantity into the count uom
      /*2977288l_system_qty :=
         inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                      6,
                                      l_system_qty,
                                      l_to_uom,
                                      g_count_uom,
                                      NULL,
                                      NULL
                                    );*/
      -- Calculate the adjusted quantity
      l_adj_qty   := l_count_qty - l_system_qty;
      -- Calculate the conversion quantity
      l_conversion_qty :=
         inv_convert.inv_um_convert ( l_item_id,
                                      5,
                                      l_adj_qty,
                                      l_from_uom,
                                      l_to_uom,
                                      NULL,
                                      NULL
                                    );
      l_value_variance := l_conversion_qty * l_item_cost;
      -- Set the OUT parameters
      x_value_variance := l_value_variance;
   END value_variance;

   FUNCTION wms_is_installed (
      p_organization_id IN NUMBER
   )
      RETURN BOOLEAN
   IS
      x_return_status VARCHAR2 ( 1 );
      x_msg_count NUMBER;
      x_msg_data VARCHAR2 ( 240 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***wms_is_installed***' );
      END IF;

      IF WMS_INSTALL.check_install ( x_return_status,
                                     x_msg_count,
                                     x_msg_data,
                                     p_organization_id
                                   ) THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END wms_is_installed;

   FUNCTION get_item_cost (
      in_org_id NUMBER,
      in_item_id NUMBER,
      in_locator_id NUMBER
   )
      RETURN NUMBER
   IS
      l_item_cost NUMBER;
      l_locator_id NUMBER := in_locator_id;
      l_cost_group_id NUMBER := g_cc_entry.cost_group_id;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

      --Begin Bug 9650524
      l_process_enabled_flag VARCHAR2(1) := 'N';
      l_result_code          VARCHAR2(30);
      l_return_status        VARCHAR2(30);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_inventory_item_id    NUMBER := in_item_id;
      l_organization_id      NUMBER := in_org_id;
      l_transaction_date     DATE   := NVL(g_cc_entry.adjustment_date, SYSDATE);
      l_cost_mthd            VARCHAR2(15);
      l_cmpntcls             NUMBER;
      l_analysis_code        VARCHAR2(15);
      l_no_of_rows           NUMBER;

      CURSOR get_process_enabled_flag IS
      SELECT NVL(process_enabled_flag, 'N')
      FROM   mtl_parameters
      WHERE  organization_id = l_organization_id;
      --End Bug 9650524

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_item_cost***' );
      END IF;

      -- We are doing this for dynamic locators
      IF ( l_locator_id = -1 ) THEN
         l_locator_id := NULL;
      END IF;

      -- Bug# 2094288
      -- For standard costed orgs, get the item cost with the common
      -- cost group ID = 1 always.  For average costed orgs, use the
      -- cost group ID stamped on the transaction
      -- Bug # 2180251: All primary costing methods not equal to 1 should
      -- also be considered as an average costed org

    -- Begin Bug 9650524
    OPEN  get_process_enabled_flag;
    FETCH get_process_enabled_flag INTO l_process_enabled_flag;
    CLOSE get_process_enabled_flag;

    IF l_process_enabled_flag = 'Y' THEN
      BEGIN
      IF(l_debug = 1) THEN
         print_debug('Calling GMF_CMCOMMON.Get_Process_Item_Cost');
      END IF;
       l_result_code := GMF_CMCOMMON.Get_Process_Item_Cost
       (   p_api_version             => 1
         , p_init_msg_list           => 'F'
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , x_msg_data                => l_msg_data
         , p_inventory_item_id       => l_inventory_item_id
         , p_organization_id         => l_organization_id
         , p_transaction_date        => l_transaction_date /* Cost as on date */
         , p_detail_flag             => 1                  /* 1 = total cost, 2 = details; 3 = cost for a specific component class/analysis code, etc. */
         , p_cost_method             => l_cost_mthd        /* OPM Cost Method */
         , p_cost_component_class_id => l_cmpntcls
         , p_cost_analysis_code      => l_analysis_code
         , x_total_cost              => l_item_cost        /* total cost */
         , x_no_of_rows              => l_no_of_rows       /* number of detail rows retrieved */
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_item_cost := 0;
       END IF;

      EXCEPTION
         WHEN OTHERS THEN
            l_item_cost := 0;
      END;
      IF(l_debug = 1) THEN
         print_debug('OPM Item Cost: ' || l_item_cost);
      END IF;
    ELSE
    -- End Bug 9650524
      BEGIN
         SELECT NVL ( ccicv.item_cost, 0 )
         INTO   l_item_cost
         FROM   cst_cg_item_costs_view ccicv,
                mtl_parameters mp
         WHERE  l_locator_id IS NULL
         AND    ccicv.organization_id = in_org_id
         AND    ccicv.inventory_item_id = in_item_id
         AND    ccicv.organization_id = mp.organization_id
         /* Bug 5555367 - Modified the condition
         AND    ccicv.cost_group_id =
                   DECODE ( mp.primary_cost_method,
                            1, 1,
                            NVL ( l_cost_group_id, 1 )
                          )
         */
         AND     ccicv.cost_group_id =
                      DECODE ( mp.primary_cost_method,
                               1, 1,
                               NVL ( l_cost_group_id, mp.default_cost_group_id)
                             )
         UNION ALL
         SELECT NVL ( ccicv.item_cost, 0 )
         FROM   mtl_item_locations mil,
                cst_cg_item_costs_view ccicv,
                mtl_parameters mp
         WHERE  l_locator_id IS NOT NULL
         AND    mil.organization_id = in_org_id
         AND    mil.inventory_location_id = l_locator_id
         AND    mil.project_id IS NULL
         AND    ccicv.organization_id = mil.organization_id
         AND    ccicv.inventory_item_id = in_item_id
         AND    ccicv.organization_id = mp.organization_id
         /* Bug 5555367 - Modified the condition
         AND    ccicv.cost_group_id =
                   DECODE ( mp.primary_cost_method,
                            1, 1,
                            NVL ( l_cost_group_id, 1 )
                          )
         */
         AND     ccicv.cost_group_id =
                      DECODE ( mp.primary_cost_method,
                               1, 1,
                               NVL ( l_cost_group_id, mp.default_cost_group_id)
                             )
         UNION ALL
         SELECT NVL ( ccicv.item_cost, 0 )
         FROM   mtl_item_locations mil,
                mrp_project_parameters mrp,
                cst_cg_item_costs_view ccicv,
                mtl_parameters mp
         WHERE  l_locator_id IS NOT NULL
         AND    mil.organization_id = in_org_id
         AND    mil.inventory_location_id = l_locator_id
         AND    mil.project_id IS NOT NULL
         AND    mrp.organization_id = mil.organization_id
         AND    mrp.project_id = mil.project_id
         AND    ccicv.organization_id = mil.organization_id
         AND    ccicv.inventory_item_id = in_item_id
         AND    ccicv.organization_id = mp.organization_id
         AND    ccicv.cost_group_id =
                   DECODE ( mp.primary_cost_method,
                            1, 1,
                            NVL (  mrp.costing_group_id, 1 )
                          );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_item_cost := 0;
      END;
    END IF;  -- Bug 9650524

      RETURN ( l_item_cost );
   END GET_ITEM_COST;

-- This function returns 2 IF a serial is not loaded ELSE returns 1
-- Added as part of bug 2640378
   FUNCTION IS_SERIAL_LOADED (
      p_organization_id IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_serial_number IN VARCHAR2,
      p_lpn_id    IN NUMBER
   )
      RETURN NUMBER
   IS
      l_serial_count NUMBER;
      l_lot_control_code NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF     p_organization_id IS NOT NULL
         AND p_serial_number IS NOT NULL
         AND p_inventory_item_id IS NOT NULL THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( '******** IS SERIAL LOADED ***********' );
         END IF;

         /*
           IF (l_debug = 1) THEN
              print_debug('Item: ===> ' ||  p_inventory_item_id);
              print_debug('Serial: => ' || p_serial_number);
              print_debug('Org ID: => ' || p_organization_id);
              print_debug('LPN ID: => ' || p_lpn_id);
           END IF;
         */
         IF p_lpn_id IS NULL THEN
            SELECT lot_control_code
            INTO   l_lot_control_code
            FROM   mtl_system_items
            WHERE  organization_id = p_organization_id
            AND    inventory_item_id = p_inventory_item_id;

            IF l_lot_control_code = 1 THEN                              -- no lot control code
                                           -- just check with msnt
               SELECT COUNT ( * )
               INTO   l_serial_count
               FROM   mtl_serial_numbers_temp s,
                      wms_loaded_quantities_v wl
               WHERE  s.transaction_temp_id = wl.transaction_temp_id
               AND    p_serial_number BETWEEN s.fm_serial_number
                                          AND s.to_serial_number;

               IF l_serial_count = 1 THEN
                  --       print_debug('Non lot controlled serial ' || p_serial_number || ' already loaded ');
                  RETURN 1;
               ELSE
                  --       print_debug('Non lot controlled serial ' || p_serial_number || ' not loaded ');
                  RETURN 2;
               END IF;
            ELSE -- have to join mtlt also
               SELECT COUNT ( * )
               INTO   l_serial_count
               FROM   mtl_serial_numbers_temp s,
                      wms_loaded_quantities_v wl,
                      mtl_transaction_lots_temp l
               WHERE  wl.transaction_temp_id = l.transaction_temp_id
               AND    s.transaction_temp_id = l.serial_transaction_temp_id
               AND    p_serial_number BETWEEN fm_serial_number
                                          AND to_serial_number;

               IF l_serial_count >= 1 THEN
                  --            print_debug('lot controlled serial ' || p_serial_number || ' already loaded ');
                  RETURN 1;
               ELSE
                  --             print_debug('lot controlled serial ' || p_serial_number || ' not loaded ');
                  RETURN 2;
               END IF;
            END IF; -- lot control code
         ELSE -- lpn is not null

--  Modified for opp cyc count 9248808
           SELECT COUNT ( * )
            INTO   l_serial_count
            FROM   mtl_serial_numbers s,
                   wms_loaded_quantities_v wl
            WHERE  s.lpn_id = p_lpn_id
--            AND    NVL ( wl.content_lpn_id, NVL ( wl.lpn_id, -1 ) ) = s.lpn_id --  Modified for opp cyc count 9248808
            AND    NVL ( wl.content_lpn_id, -1 ) = s.lpn_id
            AND    s.serial_number = p_serial_number
            AND    s.current_organization_id = p_organization_id
            AND    s.inventory_item_id = p_inventory_item_id;

            IF l_serial_count > 0 THEN -- serial is loaded
               RETURN 1;
            ELSE

							SELECT Count(DISTINCT msn.serial_number)
							INTO   l_serial_count
							FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
							WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
							AND   ((msnt.transaction_temp_id = mmtt.transaction_temp_id and
											mtlt.lot_number is null) or
										(msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
											and mtlt.lot_number is not null))
							AND    mmtt.inventory_item_id = p_inventory_item_id
							AND    mmtt.organization_id = p_organization_id
							AND    NVL ( mmtt.lpn_id, -1 ) = p_lpn_id
							AND    msn.serial_number = p_serial_number
							AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
							AND    msn.revision = mmtt.revision
							AND    msn.inventory_item_id = mmtt.inventory_item_id
							AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
							AND    wdt.transaction_temp_id = mmtt.transaction_temp_id
							AND    wdt.task_type <> 2
							AND    wdt.status = 4;


							IF l_serial_count > 0 THEN -- serial is loaded
								 RETURN 1;
							ELSE
								 RETURN 2;
							END IF;

						END IF;
         END IF; -- lpn id not/null
      ELSE -- org or serial or item is null
         RETURN 2;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 2;
   END;

   PROCEDURE is_serial_entered (
      event       IN VARCHAR2,
      entered     OUT NOCOPY NUMBER
   )
   IS
      l_serial_count_option NUMBER;
      l_serial_detail_option NUMBER;
      l_serial_detail NUMBER := g_cc_entry.serial_detail;
      l_cycle_count_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      l_number_of_counts NUMBER;
      l_counts  NUMBER := g_cc_entry.number_of_counts;
      l_last_updated_by NUMBER := g_cc_entry.last_updated_by;
      l_last_update_login NUMBER := g_cc_entry.last_update_login;
      -- for unscheduled entries
      l_sub     VARCHAR2 ( 10 ) := g_cc_entry.subinventory;
      l_lot     VARCHAR2 ( 80 ) := g_cc_entry.lot_number; -- Increased the variable size from 30 to 80 for Bug 8717805
      l_rev     VARCHAR2 ( 10 ) := g_cc_entry.revision;
      l_loc     NUMBER := g_cc_entry.locator_id;
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_system_quantity NUMBER;
      l_serial_number_control_code NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***is_serial_entered***' );
      END IF;

      -- Get the required values
      SELECT NVL ( serial_count_option, 1 ),
             NVL ( serial_detail_option, 1 )
      INTO   l_serial_count_option,
             l_serial_detail_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the serial number control code
      SELECT serial_number_control_code
      INTO   l_serial_number_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the item system quantity
      system_quantity ( x_system_quantity => l_system_quantity );
      entered     := 0;

      IF ( l_counts IS NULL ) THEN
         l_counts    := 0;
      END IF;

      IF (    event = 'WHEN-VALIDATE-RECORD'
           OR event = 'POPULATE_SERIAL_DETAIL'
         ) THEN
         IF (      (     (     l_serial_count_option = 3
                           AND l_serial_detail = 2
                           AND g_count_quantity <> l_system_quantity
                         )
                     OR ( l_serial_count_option = 3 AND l_serial_detail = 1 )
                   )
              AND ( l_serial_number_control_code IN ( 2, 5 ) )
            ) THEN
            BEGIN
               SELECT   MIN ( NVL ( number_of_counts, 0 ) )
               INTO     l_number_of_counts
               FROM     mtl_cc_serial_numbers
               WHERE    cycle_count_entry_id = l_cycle_count_entry_id
               GROUP BY cycle_count_entry_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_number_of_counts := 0;
            END;

            IF (      (     ( l_number_of_counts = 0 )
                        OR ( l_number_of_counts < l_counts )
                      )
                 AND ( event = 'WHEN-VALIDATE-RECORD' )
                 AND (    l_system_quantity <> 0
                       OR g_count_quantity <> 0 )
               ) THEN
               -- FND_MESSAGE.SET_NAME('INV', 'INV_CC_NO_SN_INFO');
               -- FND_MSG_PUB.ADD;
               -- RAISE FND_API.G_EXC_ERROR;
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'No SN info!' );
               END IF;
            ELSE
               entered     := 1;
            END IF;
         END IF;
      ELSIF event = 'OUT-TOLERANCE' THEN
         IF (      (     (     l_serial_count_option = 3
                           AND l_serial_detail = 2
                           AND ( g_count_quantity <> l_system_quantity )
                         )
                     OR ( l_serial_count_option = 3 AND l_serial_detail = 1 )
                   )
              AND ( l_serial_number_control_code IN ( 2, 5 ) )
            ) THEN
            BEGIN
               SELECT   MIN ( number_of_counts )
               INTO     l_number_of_counts
               FROM     mtl_cc_serial_numbers
               WHERE    cycle_count_entry_id = l_cycle_count_entry_id
               GROUP BY cycle_count_entry_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_number_of_counts := 0;
            END;

            IF (    l_number_of_counts = 0
                 OR l_number_of_counts < l_counts ) THEN
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_CC_OUT_TOL_NO_SN' );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               entered     := 1;
            END IF;
         END IF;
      END IF;
   END is_serial_entered;

   PROCEDURE new_serial_number
   IS
      l_serial_number VARCHAR2 ( 30 );
      l_serial_count_option NUMBER;
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_serial_detail NUMBER := g_cc_entry.serial_detail;
      l_garbage VARCHAR2 ( 30 );
      l_count   NUMBER;
      l_success BOOLEAN := FALSE;
      l_cycle_count_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      l_receipt VARCHAR2 ( 1 ) := 'R';
      l_issue   VARCHAR2(1)  := 'I';  /* Added by Bug 7229492 */
      l_serial_adjustment_option NUMBER;
      l_adjustment_quantity NUMBER := g_cc_entry.adjustment_quantity;
      l_approval_tolerance_positive NUMBER;
      l_approval_tolerance_negative NUMBER;
      l_cost_tolerance_positive NUMBER;
      l_cost_tolerance_negative NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

      --Bug 5186993
      l_automatic_recount_flag NUMBER;
      l_maximum_auto_recounts  NUMBER;
      l_days_until_late        NUMBER;
      --Bug 6978840
      l_approval_option_code   NUMBER;

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***new_serial_number***' );
      END IF;

      -- Get the required variable values
      SELECT    NVL ( serial_count_option, 1 ),
                NVL ( serial_adjustment_option, 2 ),
                NVL ( automatic_recount_flag, 2 ),
                NVL ( maximum_auto_recounts, 0 ),
                NVL ( days_until_late , 0 ),
                --Bug 6978840
                NVL ( approval_option_code , 3)
      INTO   l_serial_count_option,
             l_serial_adjustment_option,
             l_automatic_recount_flag,
             l_maximum_auto_recounts,
             l_days_until_late,
             l_approval_option_code
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      IF ( l_serial_count_option = 3 ) THEN
         -- Multiple serial number per count
         l_serial_number := g_cc_serial_entry.serial_number;

         SELECT COUNT ( * )
         INTO   l_count
         FROM   MTL_CC_SERIAL_NUMBERS
         WHERE  serial_number = l_serial_number
         AND    cycle_count_entry_id = l_cycle_count_entry_id;

         IF ( l_count > 0 ) THEN
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_DUP' );
            FND_MESSAGE.SET_TOKEN ( 'VALUE1', l_serial_number );
            FND_MSG_PUB.ADD;
            ROLLBACK TO save_serial_detail;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF ( l_serial_count_option = 2 ) THEN
         -- Single serial per count
         l_serial_number := g_cc_entry.serial_number;
      END IF;

      IF ( l_serial_number IS NULL ) THEN
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_CC_NULL_SN' );
         FND_MSG_PUB.ADD;
         l_success   := FALSE;

         IF ( l_serial_count_option = 3 ) THEN
            ROLLBACK TO save_serial_detail;
         END IF;

         RAISE FND_API.G_EXC_ERROR;
      END IF;

        IF ( l_debug = 1 ) THEN
           print_debug ( 'l_automatic_recount_flag = '||l_automatic_recount_flag||', g_cc_entry.number_of_counts = '||g_cc_entry.number_of_counts);
           print_debug ( 'l_maximum_auto_recounts = '||l_maximum_auto_recounts||', l_adjustment_quantity = '||l_adjustment_quantity);
         END IF;

       -- Bug 5186993, if automatic recount is set, check whether the adjustment has been
       -- counted the maximum number of times, if not setting for recount and return
       -- Bug 6978840 , checking if the approval option is 'If out of tolerance' and tolerance is not met

       if ( l_automatic_recount_flag = 1 AND l_serial_count_option = 2
              AND nvl(g_cc_entry.number_of_counts, 0) <= l_maximum_auto_recounts
              AND nvl(l_adjustment_quantity, 0) <> 0 ) THEN
                IF ( l_debug = 1 ) THEN
                   print_debug ( 'new_serial_number: Setting to recount' );
                END IF;
                g_serial_entry_status_code := 3;
                count_entry_status_code();
                get_final_count_info();
                g_cc_entry.count_due_date := SYSDATE + l_days_until_late;
                return;
       end if;


     /* If condition Added by 7229492 */
    if (l_adjustment_quantity < 0 and l_serial_count_option = 2)
	then
    l_success := check_serial_number_location(l_issue);
	else
    l_success := check_serial_number_location(l_receipt);
    End if;
   /* If condition Added by 7229492 */

    IF ( l_success = FALSE ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'check serial number: FALSE' );
         END IF;

         mark ( );
      ELSE
         IF ( l_debug = 1 ) THEN
            print_debug ( 'check serial number: TRUE' );
         END IF;
      END IF;

      -- Calculate if the serial is out of tolerance or not
      get_tolerances ( pre_approve_flag    => 'SERIAL',
                       x_approval_tolerance_positive => l_approval_tolerance_positive,
                       x_approval_tolerance_negative => l_approval_tolerance_negative,
                       x_cost_tolerance_positive => l_cost_tolerance_positive,
                       x_cost_tolerance_negative => l_cost_tolerance_negative
                     );
      serial_tolerance_logic ( p_serial_adj_qty    => l_adjustment_quantity,
                               p_app_tol_pos       => l_approval_tolerance_positive,
                               p_app_tol_neg       => l_approval_tolerance_negative,
                               p_cost_tol_pos      => l_cost_tolerance_positive,
                               p_cost_tol_neg      => l_cost_tolerance_negative
                             );

      IF ( g_serial_out_tolerance ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial out tolerance: TRUE' );
         END IF;
      ELSE
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial out tolerance: FALSE' );
         END IF;
      END IF;

      IF ( l_success = FALSE ) THEN
         -- mtl_serial_check.inv_qtybetwn approved our Serial_Number and
         -- inserted into MTL_SERIAL_NUMBERS table (If needed).
         -- Now we need to perform necessary adjustment transactions.

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial count option: ' || l_serial_count_option );
            print_debug (    'Serial adjustment option: '
                          || l_serial_adjustment_option
                        );
         END IF;

         IF ( l_serial_adjustment_option = 1
              AND g_serial_out_tolerance = FALSE
            ) THEN
            -- Do a serial adjustment if possible
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Trying to adjust serial' );
            END IF;

            IF ( l_serial_count_option = 2 ) THEN
               -- Single serial
               g_cc_entry.approval_condition := NULL;
               g_cc_entry.entry_status_code := 5;
               print_debug('from new_serial_number : 1');
               final_preupdate_logic ( );
            ELSIF ( l_serial_count_option = 3 ) THEN
               -- Multiple serial
               g_cc_serial_entry.approval_condition := NULL;
               g_serial_entry_status_code := 5;
               g_cc_serial_entry.pos_adjustment_qty := 1;
               g_cc_serial_entry.neg_adjustment_qty := 0;
               count_entry_status_code ( );
               perform_serial_adj_txn ( );
            END IF;
         ELSE
            -- Approvals required for serial adjustment
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Approvals required for serial adjustments' );
            END IF;

            IF ( l_serial_count_option = 2 ) THEN
               -- Single serial
               g_cc_entry.approval_condition := 3;
               g_cc_entry.entry_status_code := 2;
               print_debug('from new_serial_number : 2');
               final_preupdate_logic ( );
            ELSIF ( l_serial_count_option = 3 ) THEN
               -- Multiple serial
               g_cc_serial_entry.approval_condition := 3;
               g_serial_entry_status_code := 2;
               g_cc_serial_entry.pos_adjustment_qty := 1;
               g_cc_serial_entry.neg_adjustment_qty := 0;
               count_entry_status_code ( );
            END IF;
         END IF;
      ELSE
         -- Serial exists so no adjustment is required
         IF ( l_serial_count_option = 2 ) THEN
            -- Single serial
            g_cc_entry.entry_status_code := 5;
            print_debug('from new_serial_number : 2');
            final_preupdate_logic ( );
         ELSIF ( l_serial_count_option = 3 ) THEN
            -- Multiple serial
            g_cc_serial_entry.pos_adjustment_qty := 1;
            g_cc_serial_entry.neg_adjustment_qty := 0;
            count_entry_status_code ( );
         END IF;
      END IF;
   END new_serial_number;

   /* Deletes the serial info from mtl_cc_Serial_numbers in case of an Issue transaction */
   PROCEDURE delete_Serial_entry(p_serial_number IN VARCHAR2, p_cc_header_id IN NUMBER, p_cycle_count_entry_id IN NUMBER) IS
   BEGIN

      DELETE FROM mtl_cc_Serial_numbers
       WHERE serial_number = p_serial_number
         AND cycle_count_entry_id IN
            (SELECT cycle_count_entry_id
               FROM mtl_cycle_count_entries
              WHERE cycle_Count_header_id =   p_cc_header_id
                AND entry_status_code IN (1,3))
                   AND cycle_count_entry_id <> p_cycle_Count_entry_id;

   EXCEPTION
      WHEN OTHERS THEN
         print_debug('Exception while trying to delete serial number ' || g_cc_Serial_entry.serial_number);
   END delete_serial_entry;


   PROCEDURE existing_serial_number
   IS
      l_adjustment_quantity NUMBER := g_cc_entry.adjustment_quantity;
      l_system_present NUMBER;
      l_unit_status NUMBER;
      l_ret_value BOOLEAN := FALSE;
      l_adj_quantity NUMBER := g_cc_entry.adjustment_quantity;
      l_neg_adj_quantity NUMBER := g_cc_entry.neg_adjustment_quantity;
      l_serial_detail NUMBER := g_cc_entry.serial_detail;
      l_serial_count_option NUMBER;
      l_success BOOLEAN;
      l_issue   VARCHAR ( 1 ) := 'I';
      l_receipt VARCHAR ( 1 ) := 'R';
      l_serial_adjustment_option NUMBER;
      l_system_quantity NUMBER;
      l_primary_uom VARCHAR2 ( 3 );
      l_adjustment_value NUMBER;
      l_multiple_count NUMBER := 0;
      l_approval_tolerance_positive NUMBER;
      l_approval_tolerance_negative NUMBER;
      l_cost_tolerance_positive NUMBER;
      l_cost_tolerance_negative NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      --Bug 5186993
      l_automatic_recount_flag NUMBER;
      l_maximum_auto_recounts  NUMBER;
      l_days_until_late        NUMBER;
      l_cycle_count_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      --Bug 6978840
      l_approval_option_code   NUMBER;

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***existing_serial_number***' );

      END IF;

      -- Get the variable values
      SELECT NVL ( serial_count_option, 1 ),
             NVL ( serial_adjustment_option, 2 ),
             NVL ( automatic_recount_flag, 2 ),
             NVL ( maximum_auto_recounts, 0 ),
             NVL ( days_until_late , 0 ),
             --Bug 6978840
             NVL ( approval_option_code , 3)
      INTO   l_serial_count_option,
             l_serial_adjustment_option,
             l_automatic_recount_flag,
             l_maximum_auto_recounts,
             l_days_until_late,
             l_approval_option_code
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

        IF ( l_debug = 1 ) THEN
           print_debug ( 'l_automatic_recount_flag = '||l_automatic_recount_flag||', g_cc_entry.number_of_counts = '||g_cc_entry.number_of_counts);
           print_debug ( 'l_maximum_auto_recounts = '||l_maximum_auto_recounts||', l_adjustment_quantity = '||l_adjustment_quantity);
         END IF;

         -- Bug 5186993, if automatic recount is set, check whether the adjustment has been
         -- counted the maximum number of times, if not setting for recount and return
         -- Bug 6978840 , checking if the approval option is 'If out of tolerance' and tolerance is not met

         if ( l_automatic_recount_flag = 1 AND l_serial_count_option = 2
              AND nvl(g_cc_entry.number_of_counts, 0) <= l_maximum_auto_recounts
              AND nvl(l_adjustment_quantity, 0) <> 0 ) THEN
                IF ( l_debug = 1 ) THEN
                   print_debug ( 'existing_serial_number: Setting to recount' );
                END IF;
                g_serial_entry_status_code := 3;
                count_entry_status_code();
                get_final_count_info();
                g_cc_entry.count_due_date := SYSDATE + l_days_until_late;
                unmark(l_cycle_count_entry_id);
                return;
        end if;




      -- Set the values for g_system_present and g_unit_status
      -- Get the item system quantity
      system_quantity ( x_system_quantity => l_system_quantity );


      IF ( l_system_quantity <> 0 ) THEN
         g_system_present := 1;
      ELSE
         g_system_present := 2;
      END IF;

      IF ( g_count_quantity IS NOT NULL ) THEN
         IF ( g_count_quantity <> 0 ) THEN
            g_unit_status := 1;
         ELSE
            g_unit_status := 2;
         END IF;
      END IF;

      IF ( l_serial_count_option = 3 ) THEN
         -- Need to get the value for system present manually
         print_debug('getting the value for the sytem present manually');

         IF ( g_cc_entry.parent_lpn_id IS NULL ) THEN
            print_debug('parent_lpn_id is null');
            -- No LPN so we want to check if serial is present in the system
            -- with the given sub and loc so that if there is a discrepancy,
            -- it will pick it up and issue out and receive the serial into
            -- the sub/loc where it was found during the counting
            SELECT NVL ( SUM ( DECODE ( msn.current_status, 3, 1, 0 ) ), 0 )
            INTO   l_multiple_count
            FROM   mtl_serial_numbers msn
            WHERE  msn.serial_number = g_cc_serial_entry.serial_number
            AND    msn.inventory_item_id = g_cc_entry.inventory_item_id
            AND    msn.current_organization_id = g_cc_entry.organization_id
            AND    msn.current_subinventory_code = g_cc_entry.subinventory
            AND    NVL ( msn.lot_number, 'XX' ) =
                                           NVL ( g_cc_entry.lot_number, 'XX' )
            AND    NVL ( msn.revision, 'XXX' ) =
                                            NVL ( g_cc_entry.revision, 'XXX' )
            AND    NVL ( msn.current_locator_id, -2 ) =
                                              NVL ( g_cc_entry.locator_id, -2 )
            AND    msn.lpn_id IS NULL --Bug# 3646068
            AND    is_serial_loaded ( g_cc_entry.organization_id,
                                      g_cc_entry.inventory_item_id,
                                      g_cc_serial_entry.serial_number,
                                      NULL
                                    ) = 2;
         ELSE
            print_debug('parent_lpn_id  ' || g_cc_entry.parent_lpn_id);
            -- If the serial is inside an LPN but the LPN is discrepant, then
            -- we do not want the serial to be considered as missing here since
            -- we will do a sub transfer for the discrepant LPN which will
            -- also move the serial packed within it
            SELECT NVL ( SUM ( DECODE ( msn.current_status, 3, 1, 0 ) ), 0 )
            INTO   l_multiple_count
            FROM   mtl_serial_numbers msn
            WHERE  msn.serial_number = g_cc_serial_entry.serial_number
            AND    msn.inventory_item_id = g_cc_entry.inventory_item_id
            AND    msn.current_organization_id = g_cc_entry.organization_id
            AND    NVL ( msn.lot_number, 'XX' ) =
                                           NVL ( g_cc_entry.lot_number, 'XX' )
            AND    NVL ( msn.revision, 'XXX' ) =
                                            NVL ( g_cc_entry.revision, 'XXX' )
            AND    msn.lpn_id = g_cc_entry.parent_lpn_id
            AND    is_serial_loaded ( g_cc_entry.organization_id,
                                      g_cc_entry.inventory_item_id,
                                      g_cc_serial_entry.serial_number,
                                      g_cc_entry.parent_lpn_id
                                    ) = 2;
         END IF;

         print_debug('l_multiple_count ' ||  l_multiple_count);
         IF ( l_multiple_count <> 0 ) THEN
            g_system_present := 1;
         ELSE
            g_system_present := 2;
         END IF;

         g_unit_status := g_cc_serial_entry.unit_status_current;
      END IF;

      IF ( l_serial_count_option = 3 ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial Number: ' || g_cc_serial_entry.serial_number
                        );
         END IF;
      ELSIF ( l_serial_count_option = 2 ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial Number: ' || g_cc_entry.serial_number );
         END IF;
      END IF;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'System Present: ' || g_system_present );
         print_debug ( 'Unit Status: ' || g_unit_status );
      END IF;

      l_system_present := g_system_present;
      l_unit_status := g_unit_status;

      IF ( l_debug = 1 ) THEN
           print_debug ( 'l_system_present: ' || l_system_present );
           print_debug ( 'l_unit_status: ' || l_unit_status );
         END IF;

      -- Get the item primary uom code
      SELECT primary_uom_code
      INTO   l_primary_uom
      FROM   MTL_SYSTEM_ITEMS
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

        IF ( l_debug = 1 ) THEN
           print_debug ( 'l_primary_uom: ' || l_primary_uom );
           print_debug ( 'g_count_uom: ' || g_count_uom );
           print_debug ( 'l_primary_uom: ' || l_primary_uom );
           print_debug ( 'l_system_quantity: ' || l_system_quantity );
           print_debug ( 'g_count_quantity: ' || g_count_quantity );

         END IF;

      -- Convert the system quantity into the primary uom

         l_system_quantity :=
         inv_convert.inv_um_convert ( g_cc_entry.inventory_item_id,
                                      6,
                                      l_system_quantity,
                                      g_count_uom,
                                      l_primary_uom,
                                      NULL,
                                      NULL
                                    );
         IF ( l_debug = 1 ) THEN
            print_debug ( 'l_system_quantity: ' || l_system_quantity );
            print_debug ( 'g_count_quantity: ' || g_count_quantity );
         END IF;

      -- Get and set the adjustment quantity and adjustment value
      IF ( l_serial_count_option IN ( 2, 3 ) ) THEN
         l_adjustment_quantity := g_count_quantity - l_system_quantity;
         g_cc_entry.adjustment_quantity := l_adjustment_quantity;
         --Bug# 3640622 Commented out the code.
         --g_cc_entry.adjustment_date := SYSDATE;
         value_variance ( x_value_variance => l_adjustment_value );
         g_cc_entry.adjustment_amount := l_adjustment_value;
      END IF;

      -- Calculate if the serial is out of tolerance or not
      get_tolerances ( pre_approve_flag    => 'SERIAL',
                       x_approval_tolerance_positive => l_approval_tolerance_positive,
                       x_approval_tolerance_negative => l_approval_tolerance_negative,
                       x_cost_tolerance_positive => l_cost_tolerance_positive,
                       x_cost_tolerance_negative => l_cost_tolerance_negative
                     );
      serial_tolerance_logic ( p_serial_adj_qty    => l_adjustment_quantity,
                                p_app_tol_pos       => l_approval_tolerance_positive,
                               p_app_tol_neg       => l_approval_tolerance_negative,
                               p_cost_tol_pos      => l_cost_tolerance_positive,
                               p_cost_tol_neg      => l_cost_tolerance_negative
                             );

      IF ( g_serial_out_tolerance ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial out tolerance: TRUE' );
         END IF;
      ELSE
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial out tolerance: FALSE' );
         END IF;
      END IF;

      -- Multiple serial count option
      IF ( l_serial_count_option = 3 ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Multiple serial: existing_serial_number' );
         END IF;

         -- If the s/n is shown on the system, but was counted as missing
         -- i.e. l_system_present = 1 and l_unit_status = 2, then execute.
         -- The serial no. will not show up in our cycle count if it does
         -- not exist in the system.
         IF (  ( l_system_present = 1 ) AND ( l_unit_status = 2 ) ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug (    'Missing serial is: '
                             || g_cc_serial_entry.serial_number
                           );
               print_debug (    'serial adjustment option is: '
                             || l_serial_adjustment_option
                           );
            END IF;

            IF (     l_serial_adjustment_option = 1
                 AND g_serial_out_tolerance = FALSE
               ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Trying to make adjustment automatically' );
               END IF;

               l_success   := check_serial_number_location ( l_issue );
               g_cc_serial_entry.pos_adjustment_qty := 0;
               g_cc_serial_entry.neg_adjustment_qty := 1;

               IF ( l_success ) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location: TRUE' );
                  END IF;
               ELSE
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location: FALSE' );
                  END IF;
               END IF;

               IF ( l_success = FALSE ) THEN
                  g_serial_entry_status_code := 5;
                  g_cc_serial_entry.approval_condition := NULL;
               END IF;

               count_entry_status_code ( );
               perform_serial_adj_txn ( );
               -- If serial adjustment option is "review all adjustments", then send to approval
            ELSE
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Need to review this adjustment' );
               END IF;

               l_success   := check_serial_number_location ( l_issue );
               g_serial_entry_status_code := 2;
               g_cc_serial_entry.approval_condition := 3;
               g_cc_serial_entry.pos_adjustment_qty := 0;
               g_cc_serial_entry.neg_adjustment_qty := 1;
               count_entry_status_code ( );
            END IF;
         -- If the s/n is missing on the system, but was counted as present:

         -- This part will only be executed if after CC generation some other transaction issued
         -- out the Serial Number but the counter finds it at the count serial location.
         -- The condition where serial number never existed in the system will be handled by
         -- 'NEW' or 'INSERT' record condition
         ELSIF (  ( l_system_present = 2 ) AND ( l_unit_status = 1 ) ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug (    'Serial is counted as present: '
                             || g_cc_serial_entry.serial_number
                           );
            END IF;

            IF (     l_serial_adjustment_option = 1
                 AND g_serial_out_tolerance = FALSE
               ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Trying to make adjustment automatically' );
               END IF;

               l_success   := check_serial_number_location ( l_receipt );
               g_cc_serial_entry.pos_adjustment_qty := 1;
               g_cc_serial_entry.neg_adjustment_qty := 0;

               IF ( l_success ) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location: TRUE' );
                  END IF;
               ELSE
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location: FALSE' );
                  END IF;
               END IF;

               IF ( l_success = FALSE ) THEN
                  g_serial_entry_status_code := 5;
                  g_cc_serial_entry.approval_condition := NULL;
               END IF;

               count_entry_status_code ( );
               perform_serial_adj_txn ( );
            -- If serial adjustment option is "review all adjustments", then send to approval
            ELSE
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Need to review this adjustment' );
               END IF;

               l_success   := check_serial_number_location ( l_receipt );
               g_serial_entry_status_code := 2;
               g_cc_serial_entry.approval_condition := 3;
               g_cc_serial_entry.pos_adjustment_qty := 1;
               g_cc_serial_entry.neg_adjustment_qty := 0;
               count_entry_status_code ( );
            END IF;
         /* All other cases considered as no problem, no adjustment required */
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'All other cases with no adjustments' );
            END IF;

            g_serial_entry_status_code := 5;
            g_cc_entry.entry_status_code := 5;   /* Added for bug#4926279*/
            g_cc_serial_entry.pos_adjustment_qty := NULL;
            g_cc_serial_entry.neg_adjustment_qty := NULL;
            g_cc_serial_entry.approval_condition := NULL;
            count_entry_status_code ( );
         END IF;
      -- Single serial count option
      ELSIF ( l_serial_count_option = 2 ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Single serial: existing_serial_number' );
         END IF;

         /* If the s/n is shown on the system, but was counted as missing */
         IF ( l_adjustment_quantity = -1 ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Serial is missing: ' || g_cc_entry.serial_number
                           );
            END IF;

            IF ( l_serial_adjustment_option = 1 ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Trying to adjust the serial' );
               END IF;

               l_success   := check_serial_number_location ( l_issue );
               g_cc_entry.neg_adjustment_quantity := 1;

               IF ( l_success = FALSE ) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: FALSE'
                                 );
                  END IF;

                  g_serial_entry_status_code := 5;
                  g_cc_entry.entry_status_code := 5;
                  g_cc_entry.approval_condition := NULL;
               ELSE
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: TRUE'
                                 );
                  END IF;
               END IF;
               print_debug('from existing_Serial_number : 1');
               final_preupdate_logic ( );
            /* If serial adjustment option is "review all adjustments", then send to approval */
            ELSIF ( l_serial_adjustment_option = 2 ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Serial adjustment needs to be reviewed' );
               END IF;

               l_success   := check_serial_number_location ( l_issue );

               IF ( l_success = FALSE ) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: FALSE'
                                 );
                  END IF;
               ELSE
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: TRUE'
                                 );
                  END IF;
               END IF;

               g_serial_entry_status_code := 2;
               g_cc_entry.entry_status_code := 2;
               g_cc_entry.neg_adjustment_quantity := 1;
               g_cc_entry.approval_condition := 3;
               print_debug('from existing_Serial_number : 2');
               final_preupdate_logic ( );
            END IF;
         /* IF the s/n is missing on the system, but was count as present */
         ELSIF ( l_adjustment_quantity = 1 ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Serial is found: ' || g_cc_entry.serial_number );
            END IF;

            IF ( l_serial_adjustment_option = 1 ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Trying to adjust the serial' );
               END IF;

               l_success   := check_serial_number_location ( l_receipt );
               g_cc_entry.adjustment_quantity := 1;

               IF ( l_success = FALSE ) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: FALSE'
                                 );
                  END IF;

                  g_serial_entry_status_code := 5;
                  g_cc_entry.entry_status_code := 5;
                  g_cc_entry.approval_condition := NULL;
               ELSE
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: TRUE'
                                 );
                  END IF;
               END IF;
               print_debug('from existing_Serial_number : 3');
               final_preupdate_logic ( );
            /* if serial adjustment option is "review all adjustments", then send to approval */
            ELSIF ( l_serial_adjustment_option = 2 ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Serial adjustment needs to be reviewed' );
               END IF;

               l_success   := check_serial_number_location ( l_receipt );

               IF ( l_success = FALSE ) THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: FALSE'
                                 );
                  END IF;
               ELSE
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'check_serial_number_location returned: TRUE'
                                 );
                  END IF;
               END IF;

               g_serial_entry_status_code := 2;
               g_cc_entry.entry_status_code := 2;
               g_cc_entry.adjustment_quantity := 1;
               g_cc_entry.approval_condition := 3;
               print_debug('from existing_Serial_number : 4');
               final_preupdate_logic ( );
            END IF;
         /* all other cases considered as no problem, no adjustment required */
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'No serial adjustment needs to be made' );
            END IF;

            g_serial_entry_status_code := 5;
            g_cc_entry.entry_status_code := 5;
            g_cc_entry.neg_adjustment_quantity := NULL;
            g_cc_entry.approval_condition := NULL;
            print_debug('from existing_Serial_number : 5');
            final_preupdate_logic ( );
         END IF;
      END IF;
   END existing_serial_number;

-- Function check_serial_number_location
--
-- This function checks to see if the Serial Number where this serial number is
-- located in the system.
   FUNCTION check_serial_number_location (
      issue_receipt VARCHAR2
   )
      RETURN BOOLEAN
   IS
      u1        VARCHAR2 ( 30 );
      u2        VARCHAR2 ( 30 );
      u3        NUMBER;
      u4        VARCHAR2 ( 30 );
      u5        VARCHAR2 ( 30 );
      u6        VARCHAR2 ( 30 );
      u7        VARCHAR2 ( 3 );
      u8        VARCHAR2 ( 30 );
      u9        VARCHAR2 ( 30 );
      u10       VARCHAR2 ( 30 );
      u11       VARCHAR2 ( 3 );
      u12       VARCHAR2 ( 30 );
      u13       VARCHAR2 ( 10 );
      u14       VARCHAR2 ( 30 );
      u15       VARCHAR2 ( 1 );
      serial_count NUMBER := 0;
      l_serial_count_option NUMBER;
      l_serial_number_type NUMBER := 1;                    /* Default value */
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_serial_number VARCHAR2 ( 30 ) := g_cc_entry.serial_number;
      l_serial_detail NUMBER;
      l_serial_discrepancy NUMBER;
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_subinv  VARCHAR2 ( 10 ) := g_cc_entry.subinventory;
      l_revision VARCHAR2 ( 3 ) := g_cc_entry.revision;
      l_current_status NUMBER;
      l_ret_value BOOLEAN := FALSE;
      l_system_quantity NUMBER;
      l_dummy_quantity NUMBER;
      l_serial_number_control_code NUMBER;
      l_return_status VARCHAR2 ( 300 );
      l_msg_count NUMBER;
      l_msg_data VARCHAR2 ( 300 );
      l_error_code NUMBER;
      l_quantity NUMBER;
      l_prefix  VARCHAR2 ( 240 );
      -- Variables used for serial discrepancies
      l_msn_subinv VARCHAR2 ( 10 );
      l_msn_locator_id NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***check_serial_number_location***' );
      END IF;

      -- Get the variable values
      SELECT NVL ( serial_count_option, 1 ),
             NVL ( serial_detail_option, 1 ),
             NVL ( serial_discrepancy_option, 2 )
      INTO   l_serial_count_option,
             l_serial_detail,
             l_serial_discrepancy
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the serial number control code
      SELECT serial_number_control_code
      INTO   l_serial_number_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the item system quantity
      system_quantity ( x_system_quantity => l_system_quantity );

      IF (      ( l_system_quantity ) = 1
           AND ( g_count_quantity = 1 )
           AND ( l_serial_count_option = 2 )
         ) THEN
         l_ret_value := TRUE;
      ELSE
         IF ( l_org_id IS NOT NULL ) THEN
            SELECT SERIAL_NUMBER_TYPE
            INTO   l_serial_number_type
            FROM   MTL_PARAMETERS
            WHERE  ORGANIZATION_ID = l_org_id;
         END IF;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Got the serial number type: '
                          || l_serial_number_type
                        );
         END IF;

         IF ( l_serial_count_option = 3 ) THEN
            u1          := g_cc_serial_entry.serial_number;
            u2          := g_cc_serial_entry.serial_number;
            l_serial_number := g_cc_serial_entry.serial_number;
         ELSE
            u1          := g_cc_entry.serial_number;
            u2          := g_cc_entry.serial_number;
            l_serial_number := g_cc_entry.serial_number;
         END IF;

         u3          := g_cc_entry.system_quantity_current;
         u4          := NULL;
         u5          := g_cc_entry.inventory_item_id;
         u6          := g_cc_entry.organization_id;
         u7          := l_serial_number_type;
         u8          := g_cc_entry.cycle_count_entry_id;
         u9          := TO_CHAR ( 9 );
         u10         := l_serial_number_control_code;
         u11         := g_cc_entry.revision;
         u12         := g_cc_entry.lot_number;
         u13         := g_cc_entry.subinventory;
         u14         := g_cc_entry.locator_id;
         u15         := issue_receipt;

         -- Serial was found as missing so need to issue it out.
         IF ( issue_receipt = 'I' ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Need to issue out the serial so reset the sub and loc'
                           );
            END IF;

            SELECT CURRENT_SUBINVENTORY_CODE,
                   NVL ( CURRENT_LOCATOR_ID, 0 )
            INTO   l_msn_subinv,
                   l_msn_locator_id
            FROM   MTL_SERIAL_NUMBERS
            WHERE  SERIAL_NUMBER = u1
            AND    INVENTORY_ITEM_ID = g_cc_entry.inventory_item_id
            AND    CURRENT_ORGANIZATION_ID = g_cc_entry.organization_id;

            -- Reset these values just for calling the validation procedure
            u13         := l_msn_subinv;
            u14         := l_msn_locator_id;
         END IF;

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Calling the package mtl_serial_check.inv_qtybetwn' );
            print_debug ( 'Inputs to API are: ' );
            print_debug ( 'p_from_serial_number: =========> ' || u1 );
            print_debug ( 'p_to_serial_number: ===========> ' || u2 );
            print_debug ( 'p_item_id: ====================> ' || u5 );
            print_debug ( 'p_organization_id: ============> ' || u6 );
            print_debug ( 'p_serial_number_type: =========> ' || u7 );
            print_debug ( 'p_transaction_action_id: ======> ' || u8 );
            print_debug ( 'p_transaction_source_type_id: => ' || u9 );
            print_debug ( 'p_serial_control: =============> ' || u10 );
            print_debug ( 'p_revision: ===================> ' || u11 );
            print_debug ( 'p_lot_number: =================> ' || u12 );
            print_debug ( 'p_subinventory: ===============> ' || u13 );
            print_debug ( 'p_locator_id: =================> ' || u14 );
            print_debug ( 'p_receipt_issue_flag: =========> ' || u15 );
         END IF;

         -- Call package in file INVSERLB.PLS instead of a USER_EXIT
         mtl_serial_check.inv_qtybetwn ( p_api_version       => 0.9,
                                         x_return_status     => l_return_status,
                                         x_msg_count         => l_msg_count,
                                         x_msg_data          => l_msg_data,
                                         x_errorcode         => l_error_code,
                                         p_from_serial_number => u1,
                                         p_to_serial_number  => u2,
                                         x_quantity          => l_quantity,
                                         x_prefix            => l_prefix,
                                         p_item_id           => u5,
                                         p_organization_id   => u6,
                                         p_serial_number_type => u7,
                                         p_transaction_action_id => u8,
                                         p_transaction_source_type_id => u9,
                                         p_serial_control    => u10,
                                         p_revision          => u11,
                                         p_lot_number        => u12,
                                         p_subinventory      => u13,
                                         p_locator_id        => u14,
                                         p_receipt_issue_flag => u15
                                       );

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Error code is: ' || l_error_code );
            print_debug ( 'Issue receipt: ' || issue_receipt );
         END IF;

         IF ( l_error_code <> 0 AND issue_receipt = 'R' ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Serial number: ' || l_serial_number );
               print_debug ( 'Item ID: ' || l_item_id );
               print_debug ( 'Organization ID: ' || l_org_id );
            END IF;

            BEGIN
               SELECT 1,
                      current_status
               INTO   serial_count,
                      l_current_status
               FROM   MTL_SERIAL_NUMBERS
               WHERE  SERIAL_NUMBER = l_serial_number
               AND    INVENTORY_ITEM_ID = l_item_id
               AND    CURRENT_ORGANIZATION_ID = l_org_id
               AND    CURRENT_STATUS IN ( 1, 3 );
            EXCEPTION
               WHEN OTHERS THEN
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'SQL Error: ' || SQLCODE );
                  END IF;
            END;

            IF ( l_debug = 1 ) THEN
               print_debug ( 'serial_count: ' || serial_count );
               print_debug ( 'serial_discrepancy: ' || l_serial_discrepancy );
               print_debug ( 'serial count option: ' || l_serial_count_option );
            END IF;

            IF ( serial_count = 1 AND l_serial_discrepancy = 1 ) THEN
               IF ( l_serial_count_option = 2 ) THEN
                  g_cc_entry.approval_condition := 1;
                  g_cc_entry.entry_status_code := 2;

                  IF ( l_debug = 1 ) THEN
                     print_debug (    'entry_status_code: '
                                   || g_cc_entry.entry_status_code
                                 );
                  END IF;
               ELSIF ( l_serial_count_option = 3 ) THEN
                  g_serial_entry_status_code := 2;
                  g_cc_serial_entry.approval_condition := 1;

                  IF ( l_debug = 1 ) THEN
                     print_debug (    'entry_status_code: '
                                   || g_cc_entry.entry_status_code
                                 );
                  END IF;
               END IF;

               FND_MESSAGE.SET_NAME ( 'INV', 'INV_CC_SERIAL_MULTI_TRANSACT2' );
               FND_MESSAGE.SET_TOKEN ( 'SERIAL', l_serial_number );
               FND_MSG_PUB.ADD;

               IF ( l_debug = 1 ) THEN
                  print_debug ( 'l_current_status: ' || l_current_status );
               END IF;

               IF ( l_current_status = 1 ) THEN
                  l_ret_value := TRUE;
               ELSE
                  l_ret_value := FALSE;
               END IF;
            ELSE
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_CC_SERIAL_DISCREPANCY' );
               FND_MESSAGE.SET_TOKEN ( 'SERIAL', l_serial_number );
               FND_MSG_PUB.ADD;

               IF ( l_serial_count_option = 3 ) THEN
                  --   clear_block(NO_VALIDATE);
                  --   go_block('CC_ENTRIES');
                  --   hide_window('CC_SERIAL_ENTRY');
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Multiple serial error' );
                  END IF;

                  ROLLBACK TO save_serial_detail;
               END IF;

               RAISE FND_API.G_EXC_ERROR;
            END IF;
         ELSIF ( l_error_code <> 0 ) THEN
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_CC_SERIAL_DISCREPANCY' );
            FND_MESSAGE.SET_TOKEN ( 'SERIAL', l_serial_number );
            FND_MSG_PUB.ADD;

            IF ( l_serial_count_option = 3 ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Multiple serial error' );
               END IF;

               ROLLBACK TO save_serial_detail;
            END IF;

            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      RETURN ( l_ret_value );
   END check_serial_number_location;

   PROCEDURE perform_serial_adj_txn
   IS
      l_entry_status_code NUMBER := g_serial_entry_status_code;
      l_number_of_counts NUMBER := g_cc_serial_entry.number_of_counts;
      l_adjustment_quantity NUMBER;
      l_transaction_id NUMBER;
      l_org_id  NUMBER := g_cc_entry.organization_id;
      l_cc_header_id NUMBER := g_cc_entry.cycle_count_header_id;
      l_item_id NUMBER := g_cc_entry.inventory_item_id;
      l_sub     VARCHAR2 ( 10 ) := g_cc_entry.subinventory;
      l_txn_quantity NUMBER;
      l_txn_uom VARCHAR2 ( 3 ) := g_count_uom;
      l_lot_num VARCHAR2 ( 80 ) := g_cc_entry.lot_number; --Increased the variable size from 30 to 80 for Bug 8717805
      l_lot_exp_date DATE;
      l_rev     VARCHAR2 ( 3 ) := g_cc_entry.revision;
      l_locator_id NUMBER := g_cc_entry.locator_id;
      l_txn_ref VARCHAR2 ( 240 ) := g_cc_entry.reference_current;
      l_reason_id NUMBER := g_cc_entry.transaction_reason_id;
      l_txn_header_id NUMBER := NVL ( g_txn_header_id, -2 );
      l_txn_temp_id NUMBER;
      l_user_id NUMBER := g_user_id;
      l_login_id NUMBER := g_login_id;
      l_txn_proc_mode NUMBER := g_txn_proc_mode;
      l_txn_acct_id NUMBER;
      l_success_flag NUMBER;
      l_p_uom_qty NUMBER;
      l_cycle_count_entry_id NUMBER := g_cc_entry.cycle_count_entry_id;
      l_from_uom VARCHAR2 ( 3 );
      l_to_uom  VARCHAR2 ( 3 );
      l_txn_date DATE := SYSDATE;
      l_serial_number VARCHAR2 ( 30 ) := g_cc_serial_entry.serial_number;
      l_serial_prefix VARCHAR2 ( 30 );
      l_lpn_id  NUMBER := g_cc_entry.parent_lpn_id;
      l_cost_group_id NUMBER := g_cc_entry.cost_group_id;
      -- Variables used for handling serial discrepancies
      l_msn_subinv VARCHAR2 ( 10 );
      l_msn_lot_number VARCHAR2 ( 30 );
      l_msn_locator_id NUMBER;
      l_msn_revision VARCHAR2 ( 3 );
      l_msn_lpn_id NUMBER;
      l_current_status NUMBER;
      l_adj_qty NUMBER;
      l_temp_subinv VARCHAR2 ( 10 );
      l_temp_locator_id NUMBER;
      l_item_name VARCHAR2 ( 100 );
      -- Bug # 2743382

      v_available_quantity NUMBER;
      v_entry_status_code NUMBER;
      x_return_status VARCHAR2 ( 10 );
      x_qoh     NUMBER;
      x_att     NUMBER;
      v_ser_code NUMBER;
      v_lot_code NUMBER;
      v_rev_code NUMBER;
      v_is_ser_controlled BOOLEAN := FALSE;
      v_is_lot_controlled BOOLEAN := FALSE;
      v_is_rev_controlled BOOLEAN := FALSE;
      l_rqoh    NUMBER;
      l_qr      NUMBER;
      l_qs      NUMBER;
      l_atr     NUMBER;
      l_msg_count NUMBER;
      l_msg_data VARCHAR2 ( 2000 );
      l_parent_lpn_id NUMBER;
      l_neg_inv_rcpt_code NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_allow_neg_onhand_prof_val NUMBER;   -- 4870490
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***perform_serial_adj_txn***' );
      END IF;

        /*Bug 5704910*/
        --Clearing the quantity tree cache
        inv_quantity_tree_pub.clear_quantity_cache;

      --Bug# 3640622
      g_cc_entry.adjustment_date := SYSDATE;

      -- Get the item primary uom code
      SELECT primary_uom_code
      INTO   l_to_uom
      FROM   MTL_SYSTEM_ITEMS
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the cycle count header inventory adjustment account
      SELECT NVL ( inventory_adjustment_account, -1 )
      INTO   l_txn_acct_id
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT concatenated_segments
      INTO   l_item_name
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = l_item_id AND organization_id = l_org_id;

      l_from_uom  := g_count_uom;
      l_txn_uom   := l_from_uom;

      IF ( l_txn_date IS NULL ) THEN
         l_txn_date  := SYSDATE;
      END IF;

      IF ( l_debug = 1 ) THEN
         print_debug (    'Serial: '
                       || g_cc_serial_entry.serial_number
                       || ' Pos adj qty: '
                       || g_cc_serial_entry.pos_adjustment_qty
                       || ' Neg adj qty: '
                       || g_cc_serial_entry.neg_adjustment_qty
                     );
      END IF;

      IF ( g_cc_serial_entry.pos_adjustment_qty = 1 ) THEN
         l_adjustment_quantity := 1;
         l_txn_quantity := 1;
      ELSIF ( g_cc_serial_entry.neg_adjustment_qty = 1 ) THEN
         l_adjustment_quantity := -1;
         l_txn_quantity := -1;
      ELSE
         l_adjustment_quantity := 0;
         l_txn_quantity := 0;
      END IF;

      IF ( l_debug = 1 ) THEN
         print_debug (    'Multiple serial entry status code: '
                       || l_entry_status_code
                     );
         print_debug ( 'Adjustment quantity: ' || l_adjustment_quantity );
      END IF;

      IF ( l_entry_status_code = 5 AND l_adjustment_quantity <> 0 ) THEN
         IF ( l_txn_header_id = -2 ) THEN
            SELECT mtl_material_transactions_s.NEXTVAL
            INTO   l_txn_header_id
            FROM   DUAL;

            g_txn_header_id := l_txn_header_id;
         END IF;

         SELECT mtl_material_transactions_s.NEXTVAL
         INTO   l_txn_temp_id
         FROM   DUAL;

         SELECT auto_serial_alpha_prefix
         INTO   l_serial_prefix
         FROM   mtl_system_items
         WHERE  inventory_item_id = l_item_id AND organization_id = l_org_id;

         l_p_uom_qty :=
            inv_convert.inv_um_convert ( l_item_id,
                                         5,
                                         l_txn_quantity,
                                         l_from_uom,
                                         l_to_uom,
                                         NULL,
                                         NULL
                                       );

         -- Bug 3296675, we need to delete cycle count reservations before checking for availability.
         delete_reservation ( );

         -- Bug # 2743382

         SELECT negative_inv_receipt_code
         INTO   l_neg_inv_rcpt_code --Negative Balance  1:Allowed   2:Disallowed
         FROM   mtl_parameters
         WHERE  organization_id = l_org_id;

         --4870490
         l_allow_neg_onhand_prof_val := NVL(FND_PROFILE.VALUE('INV_ALLOW_CC_TXNS_ONHAND_NEG'),2);


         -- Bug number 4469742 commented the IF clause here AS per the discussion WITH the PM
         -- for the complete opinion from the PM please refer to the update in the bug
         --*** JSHERMAN  07/01/05 02:44 pm ***
         -- after this the check IF (v_available_quantity + v_adjustment_quantity < 0)  will happen
         -- irrespective of the the l_neg_inv_rcpt_code flag value

    --  IF ( l_neg_inv_rcpt_code = 2 ) THEN

            SELECT serial_number_control_code,
                   lot_control_code,
                   revision_qty_control_code
            INTO   v_ser_code,
                   v_lot_code,
                   v_rev_code
            FROM   mtl_system_items
            WHERE  inventory_item_id = l_item_id
                   AND organization_id = l_org_id;

            IF ( v_ser_code <> 1 ) THEN
               v_is_ser_controlled := TRUE;
            END IF;

            IF ( v_lot_code <> 1 ) THEN
               v_is_lot_controlled := TRUE;
            END IF;

            IF ( v_rev_code <> 1 ) THEN
               v_is_rev_controlled := TRUE;
            END IF;

            inv_quantity_tree_pub.query_quantities ( p_api_version_number => 1.0,
                                                     p_init_msg_lst      => 'F',
                                                     x_return_status     => x_return_status,
                                                     x_msg_count         => l_msg_count,
                                                     x_msg_data          => l_msg_data,
                                                     p_organization_id   => l_org_id,
                                                     p_inventory_item_id => l_item_id,
                                                     p_tree_mode         => 1,
                                                     p_is_revision_control => v_is_rev_controlled,
                                                     p_is_lot_control    => v_is_lot_controlled,
                                                     p_is_serial_control => v_is_ser_controlled,
                                                     p_demand_source_type_id => NULL,
                                                     p_revision          => l_rev,
                                                     p_lot_number        => l_lot_num,
                                                     p_lot_expiration_date => l_lot_exp_date,
                                                     p_subinventory_code => l_sub,
                                                     p_locator_id        => l_locator_id,
                                                     p_onhand_source     => 3,
                                                     x_qoh               => x_qoh,
                                                     x_rqoh              => l_rqoh,
                                                     x_qr                => l_qr,
                                                     x_qs                => l_qs,
                                                     x_att               => x_att,
                                                     x_atr               => l_atr
                                                   );
            v_available_quantity := x_att;

               /* Bug Number 4690372
               Profile Value : Yes-1
               No/NUll- 2
               l_neg_rcpt_code 1- Allow
               2-Disallow

               Approval Option  L-Neg_rcpot Code   Profile Value    Behaviour

               Always             1                 1                Allows Approval
               Always             1                 2                On Approval Error is shown
               Always             2                 1                On Approval Error is shown
               Always             2                 2                On Approval Error is shown


               Approval Option  L-Neg_rcpot Code   Profile Value    Behaviour

               Never             1                 1                Adjustments happen at entry
               Never             1                 2                Adjustments Deferrred to Approval
               Never             2                 1                Adjustments Deferrred to Approval
               Never             2                 2                Adjustments Deferrred to Approval
               */


               --Bug 5095970, changing l_atr to x_att since for non-reservable subs l_atr will be 0
               IF ( v_available_quantity + l_adjustment_quantity < 0 AND l_entry_status_code = 5)
               AND (l_allow_neg_onhand_prof_val = 2 OR l_neg_inv_rcpt_code = 2  )
               THEN
               -- The cycle count adjustment should not be processed since it will
               -- invalidate an existing reservation/allocation.

               -- Reset the approval related colums in the cycle count entry record
               g_cc_entry.approval_type := NULL;
               g_cc_entry.approver_employee_id := NULL;
               g_cc_entry.approval_date := NULL;
               -- Reset the entry status code to 2: Approval required
               -- Do this for both the local variable as well as the global cycle count
               -- entry record
               g_cc_entry.entry_status_code := 2;
               l_entry_status_code := 2;
            END IF;


            -- Bug number 4469742 moved the IF clause here AS per the discussion WITH the PM
           -- for the complete opinion from the PM please refer to the update in the bug
            --*** JSHERMAN  07/01/05 02:44 pm ***
           -- after this the check IF (v_available_quantity + v_adjustment_quantity < 0)  will happen
           -- irrespective of the the l_neg_inv_rcpt_code flag value

      IF ( l_neg_inv_rcpt_code = 2 ) THEN

            inv_quantity_tree_pub.update_quantities ( p_api_version_number => 1.0,
                                                      p_init_msg_lst      => 'F',
                                                      x_return_status     => x_return_status,
                                                      x_msg_count         => l_msg_count,
                                                      x_msg_data          => l_msg_data,
                                                      p_organization_id   => l_org_id,
                                                      p_inventory_item_id => l_item_id,
                                                      p_tree_mode         => 1,
                                                      p_is_revision_control => v_is_rev_controlled,
                                                      p_is_lot_control    => v_is_lot_controlled,
                                                      p_is_serial_control => v_is_ser_controlled,
                                                      p_demand_source_type_id => NULL,
                                                      p_revision          => l_rev,
                                                      p_lot_number        => l_lot_num,
                                                      p_subinventory_code => l_sub,
                                                      p_locator_id        => l_locator_id,
                                                      p_onhand_source     => 3,
                                                      p_containerized     => 0,
                                                      p_primary_quantity  => ABS ( l_adjustment_quantity
                                                                                 ),
                                                      p_quantity_type     => 5,
                                                      x_qoh               => x_qoh,
                                                      x_rqoh              => l_rqoh,
                                                      x_qr                => l_qr,
                                                      x_qs                => l_qs,
                                                      x_att               => x_att,
                                                      x_atr               => l_atr,
                                                      p_lpn_id            => NULL --added for lpn reservation
                                                    );
         END IF;

         -- Check to see if the serial number is found
         -- in a discrepant location or not
         SELECT NVL ( REVISION, 'XXX' ),
                NVL ( LOT_NUMBER, 'X' ),
                CURRENT_STATUS,
                CURRENT_SUBINVENTORY_CODE,
                NVL ( CURRENT_LOCATOR_ID, 0 ),
                NVL ( LPN_ID, -99 )
         INTO   l_msn_revision,
                l_msn_lot_number,
                l_current_status,
                l_msn_subinv,
                l_msn_locator_id,
                l_msn_lpn_id
         FROM   MTL_SERIAL_NUMBERS
         WHERE  SERIAL_NUMBER = l_serial_number
         AND    INVENTORY_ITEM_ID = g_cc_entry.inventory_item_id
         AND    CURRENT_ORGANIZATION_ID = g_cc_entry.organization_id;

         -- If serial number exist with status 3 but at a different loc or revision etc.
         -- than we first need to issue out the original serial number and then process
         -- the receipt transaction.  Additionally, if the serial is found
         -- in a different LPN than what is in the system, it will also
         -- issue out the serial first before receiving it back into inventory

         IF (     l_current_status = 3
              AND l_adjustment_quantity = 1
              AND (    l_msn_lpn_id <> NVL ( g_cc_entry.parent_lpn_id, -99 )
                    OR (      (    l_msn_revision <> g_cc_entry.revision
                                OR l_msn_lot_number <> g_cc_entry.lot_number
                                OR l_msn_subinv <> g_cc_entry.subinventory
                                OR l_msn_locator_id <> g_cc_entry.locator_id
                              )
                         AND l_msn_lpn_id = -99
                         AND g_cc_entry.parent_lpn_id IS NULL
                       )
                  )
            ) THEN
            IF ( l_msn_revision = 'XXX' ) THEN
               l_msn_revision := NULL;
            END IF;

            IF ( l_msn_lot_number = 'X' ) THEN
               l_msn_lot_number := NULL;
            END IF;

            IF ( l_msn_locator_id = 0 ) THEN
               l_msn_locator_id := NULL;
            END IF;

            IF ( l_msn_lpn_id = -99 ) THEN
               l_msn_lpn_id := NULL;
            END IF;

            l_adj_qty   := -1;

            IF ( l_debug = 1 ) THEN
               print_debug ( 'Serial discrepancy exists so issue out the serial first'
                           );
               print_debug ( 'Calling cc_transact with the following parameters: '
                           );
               print_debug ( 'org_id: ========> ' || l_org_id );
               print_debug ( 'cc_header_id: ==> ' || l_cc_header_id );
               print_debug ( 'item_id: =======> ' || l_item_id );
               print_debug ( 'sub: ===========> ' || l_msn_subinv );
               print_debug ( 'puomqty: =======> ' || -l_p_uom_qty );
               print_debug ( 'txnqty: ========> ' || l_adj_qty );
               print_debug ( 'txnuom: ========> ' || l_txn_uom );
               print_debug ( 'txndate: =======> ' || l_txn_date );
               print_debug ( 'txnacctid: =====> ' || l_txn_acct_id );
               print_debug ( 'lotnum: ========> ' || l_msn_lot_number );
               print_debug ( 'lotexpdate: ====> ' || l_lot_exp_date );
               print_debug ( 'rev: ===========> ' || l_msn_revision );
               print_debug ( 'locator_id: ====> ' || l_msn_locator_id );
               print_debug ( 'txnref: ========> ' || l_txn_ref );
               print_debug ( 'reasonid: ======> ' || l_reason_id );
               print_debug ( 'userid: ========> ' || l_user_id );
               print_debug ( 'cc_entry_id: ===> ' || l_cycle_count_entry_id );
               print_debug ( 'loginid: =======> ' || l_login_id );
               print_debug ( 'txnprocmode: ===> ' || l_txn_proc_mode );
               print_debug ( 'txnheaderid: ===> ' || l_txn_header_id );
               print_debug ( 'serialnum: =====> ' || l_serial_number );
               print_debug ( 'txntempid: =====> ' || l_txn_temp_id );
               print_debug ( 'serialprefix: ==> ' || l_serial_prefix );
               print_debug ( 'lpn_id: ========> ' || l_msn_lpn_id );
               print_debug ( 'cost_group_id: => ' || l_cost_group_id );
               print_debug ( ' ' );
            END IF;

            l_success_flag :=
               mtl_cc_transact_pkg.cc_transact ( org_id              => l_org_id,
                                                 cc_header_id        => l_cc_header_id,
                                                 item_id             => l_item_id,
                                                 sub                 => l_msn_subinv,
                                                 puomqty             => -l_p_uom_qty,
                                                 txnqty              => l_adj_qty,
                                                 txnuom              => l_txn_uom,
                                                 txndate             => l_txn_date,
                                                 txnacctid           => l_txn_acct_id,
                                                 lotnum              => l_msn_lot_number,
                                                 lotexpdate          => l_lot_exp_date,
                                                 rev                 => l_msn_revision,
                                                 locator_id          => l_msn_locator_id,
                                                 txnref              => l_txn_ref,
                                                 reasonid            => l_reason_id,
                                                 userid              => l_user_id,
                                                 cc_entry_id         => l_cycle_count_entry_id,
                                                 loginid             => l_login_id,
                                                 txnprocmode         => l_txn_proc_mode,
                                                 txnheaderid         => l_txn_header_id,
                                                 serialnum           => l_serial_number,
                                                 txntempid           => l_txn_temp_id,
                                                 serialprefix        => l_serial_prefix,
                                                 lpn_id              => l_msn_lpn_id,
                                                 cost_group_id       => l_cost_group_id
                                               );

            IF ( l_debug = 1 ) THEN
               print_debug ( 'success_flag: ' || l_success_flag );
               print_debug('Calling delete_Serial_entry 1');
            END IF;

            delete_serial_entry(l_serial_number,l_cc_header_id,l_cycle_count_entry_id); --3595723 Delete the serial info from mtl_cc_Serial_numbers


            --If success flag is 2 or 3 then set the message for invalid
            --material status for the lot/serial and the item combination
            IF ( NVL ( l_success_flag, -1 ) < 0 ) THEN
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_ADJ_TXN_FAILED' );
               FND_MSG_PUB.ADD;
               ROLLBACK TO save_serial_detail;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF NVL ( l_success_flag, -1 ) = 2 THEN
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_LOT_NA_DUE_MS' );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_msn_lot_number );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF NVL ( l_success_flag, -1 ) = 3 THEN
               FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_SER_NA_DUE_MS' );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_serial_number );
               FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- Get a new txn temp ID for receiving the serial back into inventory
            SELECT mtl_material_transactions_s.NEXTVAL
            INTO   l_txn_temp_id
            FROM   DUAL;
         END IF;

         IF ( l_adjustment_quantity = 1 ) THEN
            -- Receiving the serial into the sub and loc where it was found
            l_temp_subinv := l_sub;
            l_temp_locator_id := l_locator_id;
         ELSIF ( l_adjustment_quantity = -1 ) THEN
            -- Issuing out the serial from the sub and loc where
            -- the system thinks it currently is
            l_temp_subinv := l_msn_subinv;
            IF ( l_msn_locator_id = 0 ) THEN --  Start bug 7700461
               l_msn_locator_id := NULL;
            END IF;                          --  End bug 7700461
            l_temp_locator_id := l_msn_locator_id;
            IF ( l_debug = 1 ) THEN
               print_debug('Calling delete_Serial_entry 2');
            END IF;
            delete_serial_entry(l_serial_number,l_cc_header_id,l_cycle_count_entry_id); --3595723 Delete the serial info from mtl_cc_Serial_numbers
         END IF;

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Calling cc_transact with the following parameters: '
                        );
            print_debug ( 'org_id: ===========> ' || l_org_id );
            print_debug ( 'cc_header_id: =====> ' || l_cc_header_id );
            print_debug ( 'item_id: ==========> ' || l_item_id );
            print_debug ( 'sub: ==============> ' || l_temp_subinv );
            print_debug ( 'puomqty: ==========> ' || l_p_uom_qty );
            print_debug ( 'txnqty: ===========> ' || l_txn_quantity );
            print_debug ( 'txnuom: ===========> ' || l_txn_uom );
            print_debug ( 'txndate: ==========> ' || l_txn_date );
            print_debug ( 'txnacctid: ========> ' || l_txn_acct_id );
            print_debug ( 'lotnum: ===========> ' || l_lot_num );
            print_debug ( 'lotexpdate: =======> ' || l_lot_exp_date );
            print_debug ( 'rev: ==============> ' || l_rev );
            print_debug ( 'locator_id: =======> ' || l_temp_locator_id );
            print_debug ( 'txnref: ===========> ' || l_txn_ref );
            print_debug ( 'reasonid: =========> ' || l_reason_id );
            print_debug ( 'userid: ===========> ' || l_user_id );
            print_debug ( 'cc_entry_id: ======> ' || l_cycle_count_entry_id );
            print_debug ( 'loginid: ==========> ' || l_login_id );
            print_debug ( 'txnprocmode: ======> ' || l_txn_proc_mode );
            print_debug ( 'txnheaderid: ======> ' || l_txn_header_id );
            print_debug ( 'serialnum: ========> ' || l_serial_number );
            print_debug ( 'txntempid: ========> ' || l_txn_temp_id );
            print_debug ( 'serialprefix: =====> ' || l_serial_prefix );
            print_debug ( 'lpn_id: ===========> ' || l_lpn_id );
            print_debug ( 'cost_group_id: ====> ' || l_cost_group_id );
            print_debug ( ' ' );
         END IF;

         l_success_flag :=
            mtl_cc_transact_pkg.cc_transact ( org_id              => l_org_id,
                                              cc_header_id        => l_cc_header_id,
                                              item_id             => l_item_id,
                                              sub                 => l_temp_subinv,
                                              puomqty             => l_p_uom_qty,
                                              txnqty              => l_txn_quantity,
                                              txnuom              => l_txn_uom,
                                              txndate             => l_txn_date,
                                              txnacctid           => l_txn_acct_id,
                                              lotnum              => l_lot_num,
                                              lotexpdate          => l_lot_exp_date,
                                              rev                 => l_rev,
                                              locator_id          => l_temp_locator_id,
                                              txnref              => l_txn_ref,
                                              reasonid            => l_reason_id,
                                              userid              => l_user_id,
                                              cc_entry_id         => l_cycle_count_entry_id,
                                              loginid             => l_login_id,
                                              txnprocmode         => l_txn_proc_mode,
                                              txnheaderid         => l_txn_header_id,
                                              serialnum           => l_serial_number,
                                              txntempid           => l_txn_temp_id,
                                              serialprefix        => l_serial_prefix,
                                              lpn_id              => l_lpn_id,
                                              cost_group_id       => l_cost_group_id
                                            );

         IF ( l_debug = 1 ) THEN
            print_debug ( 'success_flag: ' || l_success_flag );
         END IF;

         --If success flag is 2 or 3 then set the message for invalid
         --material status for the lot/serial and the item combination
         --IF NVL(l_txn_header_id, -1) < 0 OR
         IF NVL ( l_success_flag, -1 ) < 0 THEN
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_ADJ_TXN_FAILED' );
            FND_MSG_PUB.ADD;
            ROLLBACK TO save_serial_detail;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF NVL ( l_success_flag, -1 ) = 2 THEN
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_LOT_NA_DUE_MS' );
            FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_lot_num );
            FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF NVL ( l_success_flag, -1 ) = 3 THEN
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_TRX_SER_NA_DUE_MS' );
            FND_MESSAGE.SET_TOKEN ( 'TOKEN1', l_serial_number );
            FND_MESSAGE.SET_TOKEN ( 'TOKEN2', l_item_name );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Set the commit status flag so that the TM will be called in the
         -- post commit procedure
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Setting the g_commit_status_flag := 1' );
         END IF;

         g_commit_status_flag := 1;
         g_cc_entry.inventory_adjustment_account := l_txn_acct_id;
      END IF;
   END perform_serial_adj_txn;

   PROCEDURE count_entry_status_code
   IS
      l_count_esc NUMBER := g_count_entry_status_code;
      l_serial_esc NUMBER := g_serial_entry_status_code;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***count_entry_status_code***' );
         print_debug ( 'Count Entry Status: ' || l_count_esc );
         print_debug ( 'Serial Entry Status: ' || l_serial_esc );
      END IF;

      IF (    l_count_esc IS NULL
           OR l_count_esc = 1 ) THEN
         g_count_entry_status_code := l_serial_esc;
      ELSE
         IF ( l_count_esc > l_serial_esc ) THEN
            g_count_entry_status_code := l_serial_esc;
         END IF;
      END IF;
   END count_entry_status_code;

   PROCEDURE update_serial_row
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***update_serial_row***' );
      END IF;

      -- Set the WHO column information
      g_cc_serial_entry.last_update_date := SYSDATE;
      g_cc_serial_entry.last_updated_by := g_user_id;
      g_cc_serial_entry.last_update_login := g_login_id;

      UPDATE MTL_CC_SERIAL_NUMBERS
      SET last_update_date = g_cc_serial_entry.last_update_date,
          last_updated_by = g_cc_serial_entry.last_updated_by,
          last_update_login = g_cc_serial_entry.last_update_login,
          number_of_counts = g_cc_serial_entry.number_of_counts,
          unit_status_current = g_cc_serial_entry.unit_status_current,
          unit_status_prior = g_cc_serial_entry.unit_status_prior,
          unit_status_first = g_cc_serial_entry.unit_status_first,
          approval_condition = g_cc_serial_entry.approval_condition,
          pos_adjustment_qty = g_cc_serial_entry.pos_adjustment_qty,
          neg_adjustment_qty = g_cc_serial_entry.neg_adjustment_qty
      WHERE  cycle_count_entry_id = g_cc_entry.cycle_count_entry_id
      AND    (     ( serial_number = g_cc_serial_entry.serial_number )
               OR (     serial_number IS NULL
                    AND g_cc_serial_entry.serial_number IS NULL
                  )
             );

      IF ( SQL%NOTFOUND ) THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END update_serial_row;

   PROCEDURE mark
   IS
      g1        VARCHAR2 ( 30 );
      g2        VARCHAR2 ( 30 );
      g3        NUMBER;
      g4        NUMBER;
      g5        NUMBER;
      g6        NUMBER;
      g7        NUMBER;
      success   NUMBER := 1;
      l_serial_number_ctrl_code NUMBER;
      l_serial_count_option NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***mark***' );
      END IF;

      -- Get the required values
      SELECT serial_number_control_code
      INTO   l_serial_number_ctrl_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_count_option, 1 )
      INTO   l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      IF ( l_serial_number_ctrl_code IN ( 2, 5 ) ) THEN
         IF ( l_serial_count_option = 2 ) THEN
            g1          := g_cc_entry.serial_number;
            g2          := g_cc_entry.serial_number;
         ELSIF ( l_serial_count_option = 3 ) THEN
            g1          := g_serial_number;
            g2          := g_serial_number;
         END IF;
      END IF;

      g3          := g_cc_entry.inventory_item_id;
      g4          := g_cc_entry.organization_id;
      g5          := g_cc_entry.cycle_count_header_id;
      g6          := g_cc_entry.cycle_count_entry_id;
      g7          := NULL;

      -- Call the procedure to mark the serial only if the entry is serial
      -- controlled and the cycle count header is single serial
      IF ( l_debug = 1 ) THEN
         print_debug (    'Serial number control code: '
                       || l_serial_number_ctrl_code
                     );
         print_debug ( 'Serial count option: ' || l_serial_count_option );
      END IF;

      IF (      ( l_serial_number_ctrl_code IN ( 2, 5 ) )
           AND ( l_serial_count_option = 2 )
         ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Calling serial_check.inv_mark_serial with the following parameters: '
                        );
            print_debug ( 'from_serial_number: => ' || g1 );
            print_debug ( 'to_serial_number: ===> ' || g2 );
            print_debug ( 'item_id: ============> ' || g3 );
            print_debug ( 'org_id: =============> ' || g4 );
            print_debug ( 'hdr_id: =============> ' || g5 );
            print_debug ( 'temp_id: ============> ' || g6 );
            print_debug ( 'lot_temp_id: ========> ' || g7 );
            print_debug ( ' ' );
         END IF;

         serial_check.inv_mark_serial ( from_serial_number  => g1,
                                        to_serial_number    => g2,
                                        item_id             => g3,
                                        org_id              => g4,
                                        hdr_id              => g5,
                                        temp_id             => g6,
                                        lot_temp_id         => g7,
                                        success             => success
                                      );

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Return value of success: ' || success );
         END IF;

         -- A return success value of -1 means that the serial has already
         -- been marked.  We don't need to error out in this case.
         IF ( success < -1 ) THEN
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_SERIAL_UNAVAILABLE' );
            FND_MESSAGE.SET_TOKEN ( 'FIRST-SERIAL', g1 );
            FND_MSG_PUB.ADD;

            IF ( l_serial_count_option = 3 ) THEN
               ROLLBACK TO save_serial_detail;
            END IF;

            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END mark;

   PROCEDURE unmark (
      cycle_cnt_entry_id NUMBER
   )
   IS
      g1        VARCHAR2 ( 30 );
      g2        VARCHAR2 ( 30 );
      g3        NUMBER;
      g4        NUMBER;
      g5        NUMBER;
      g6        NUMBER;
      g7        NUMBER;
      l_serial_number_ctrl_code NUMBER;
      l_serial_count_option NUMBER;
      l_current_serial VARCHAR2 ( 30 );
      l_current_item NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***unmark***' );
      END IF;

      -- Get the required values
      SELECT serial_number_control_code
      INTO   l_serial_number_ctrl_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_count_option, 1 )
      INTO   l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      SELECT NVL ( serial_number, '@@@@@' ),
             inventory_item_id
      INTO   l_current_serial,
             l_current_item
      FROM   mtl_cycle_count_entries
      WHERE  cycle_count_entry_id = cycle_cnt_entry_id;

      -- Old call to serial_check.inv_unmark_serial
      --g1 := NULL;
      --g2 := NULL;
      --g3 := l_serial_number_ctrl_code;
      --g4 := g_cc_entry.cycle_count_header_id;
      --g5 := cycle_cnt_entry_id;
      --g6 := NULL;

      -- New call to serial_check.inv_unmark_serial
      -- For performance reasons, pass the serial number and item id
      -- instead since these are the primary keys for MTL_SERIAL_NUMBERS
      IF ( l_serial_number_ctrl_code IN ( 2, 5 ) ) THEN
         IF ( l_serial_count_option = 2 ) THEN
            g1          := l_current_serial;
            g2          := l_current_serial;
         ELSIF ( l_serial_count_option = 3 ) THEN
            g1          := g_serial_number;
            g2          := g_serial_number;
         END IF;
      END IF;

      g3          := l_serial_number_ctrl_code;
      g4          := NULL;
      g5          := NULL;
      g6          := NULL;
      g7          := l_current_item;

      -- Call the procedure to unmark the serial only if the entry is serial
      -- controlled and the cycle count header is single serial
      IF ( l_debug = 1 ) THEN
         print_debug (    'Serial number control code: '
                       || l_serial_number_ctrl_code
                     );
         print_debug ( 'Serial count option: ' || l_serial_count_option );
      END IF;

      IF (      ( l_serial_number_ctrl_code IN ( 2, 5 ) )
           AND ( l_serial_count_option = 2 )
         ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Calling serial_check.inv_unmark_serial with the following parameters: '
                        );
            print_debug ( 'from_serial_number: ==> ' || g1 );
            print_debug ( 'to_serial_number: ====> ' || g2 );
            print_debug ( 'serial_code: =========> ' || g3 );
            print_debug ( 'hdr_id: ==============> ' || g4 );
            print_debug ( 'temp_id: =============> ' || g5 );
            print_debug ( 'lot_temp_id: =========> ' || g6 );
            print_debug ( 'p_inventory_item_id: => ' || g7 );
            print_debug ( ' ' );
         END IF;

         serial_check.inv_unmark_serial ( from_serial_number  => g1,
                                          to_serial_number    => g2,
                                          serial_code         => g3,
                                          hdr_id              => g4,
                                          temp_id             => g5,
                                          lot_temp_id         => g6,
                                          p_inventory_item_id => g7
                                        );
      END IF;
   END unmark;

   PROCEDURE get_profiles
   IS
      v_user_id NUMBER;
      v_login_id NUMBER;
      profile_name VARCHAR2 ( 60 );
      profile_val VARCHAR2 ( 80 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_profiles***' );
      END IF;

      v_login_id  := fnd_global.login_id;
      g_login_id  := v_login_id;
      -- Get profile option for transaction date validation
      profile_name := 'TRANSACTION_PROCESS_MODE';
      profile_val := FND_PROFILE.VALUE ( profile_name );

      IF ( profile_val = 4 ) THEN
         -- Get form level profile
         profile_name := 'CYCLE_COUNT_ENTRIES_TXN';
         profile_val := FND_PROFILE.VALUE ( profile_name );
      END IF;

      g_txn_proc_mode := profile_val;
   END get_profiles;

   PROCEDURE get_employee (
      p_organization_id IN NUMBER
   )
   IS
      l_employee_id NUMBER;
      l_employee_full_name VARCHAR2 ( 240 );
      l_user_id NUMBER := g_user_id;
      l_org_id  NUMBER := p_organization_id;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_employee***' );
      END IF;

      BEGIN
         SELECT mec.full_name,
                fus.employee_id
         INTO   l_employee_full_name,
                l_employee_id
         FROM   mtl_employees_current_view mec,
                fnd_user fus
         WHERE  fus.user_id = l_user_id
         AND    mec.employee_id = fus.employee_id
         AND    mec.organization_id = l_org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- Just get the employee ID if the employee
            -- is not properly defined in the MTL_EMPLOYEES_CURRENT_VIEW
            SELECT fus.employee_id
            INTO   l_employee_id
            FROM   fnd_user fus
            WHERE  fus.user_id = l_user_id;

            l_employee_full_name := NULL;
      END;

      g_employee_id := l_employee_id;
      g_employee_full_name := l_employee_full_name;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_employee_id := NULL;
         g_employee_full_name := NULL;
   END get_employee;

   PROCEDURE process_summary (
      p_cycle_count_header_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_subinventory IN VARCHAR2,
      p_locator_id IN NUMBER,
      p_parent_lpn_id IN NUMBER,
      p_unscheduled_count_entry IN NUMBER,
      p_user_id   IN NUMBER
   )
   IS
      l_current_lpn NUMBER;
      l_temp_uom_code VARCHAR2 ( 3 );

      CURSOR nested_lpn_cursor
      IS
         SELECT     *
         FROM       WMS_LICENSE_PLATE_NUMBERS
         START WITH lpn_id = p_parent_lpn_id
         CONNECT BY parent_lpn_id = PRIOR lpn_id;

      CURSOR lpn_contents_cursor
      IS
         SELECT *
         FROM   WMS_LPN_CONTENTS
         WHERE  parent_lpn_id = l_current_lpn
         AND    NVL ( serial_summary_entry, 2 ) = 2;

      CURSOR lpn_serial_contents_cursor
      IS
         SELECT *
         FROM   MTL_SERIAL_NUMBERS
         WHERE  lpn_id = l_current_lpn;

      CURSOR lpn_multiple_serial_cursor
      IS
         SELECT *
         FROM   WMS_LPN_CONTENTS
         WHERE  parent_lpn_id = l_current_lpn AND serial_summary_entry = 1;

      --Bug#4891370.Added new cursor to query loaded quantity from LPN.
         CURSOR lpn_loaded_quantity_cur(p_inventory_item_id NUMBER,p_organization_id NUMBER,p_lpn_id NUMBER)
         IS
            SELECT NVL ( SUM ( quantity ), 0 )
            FROM   WMS_LOADED_QUANTITIES_V WLQV
            WHERE  WLQV.inventory_item_id = p_inventory_item_id
            AND    WLQV.organization_id = p_organization_id
            AND    (lpn_id = p_lpn_id OR content_lpn_id = p_lpn_id )
            AND    qty_type = 'LOADED';


      l_serial_count_option NUMBER;
      l_temp_count NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_lpn_loaded_qty NUMBER; --Bug#4891370
      l_cnt_qty NUMBER; --Added for bug#4886188
      l_lpn_context  NUMBER; --Added for bug#4886188

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***process_summary***' );
      END IF;
      g_lpn_summary_count := TRUE; --9452528.

      -- Get the serial count option first
      SELECT NVL ( serial_count_option, 1 )
      INTO   l_serial_count_option
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = p_cycle_count_header_id
      AND    organization_id = p_organization_id;

      /* Use the cursor that searches through all levels in the parent child relationship */
      FOR v_lpn_id IN nested_lpn_cursor
      LOOP
         l_current_lpn := v_lpn_id.lpn_id;

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Current LPN: ' || l_current_lpn );
         END IF;

         -- Process the count entry for the LPN item itself if it is associated with
         -- an inventory item
         IF ( v_lpn_id.inventory_item_id IS NOT NULL ) THEN
            -- Make sure that this inventory item is defined in the
            -- cycle count header item scope
            SELECT COUNT ( * )
            INTO   l_temp_count
            FROM   mtl_cycle_count_items
            WHERE  inventory_item_id = v_lpn_id.inventory_item_id
            AND    cycle_count_header_id = p_cycle_count_header_id;

            IF ( l_temp_count <> 0 ) THEN
               /* Get the primary UOM for the container inventory item */
               SELECT primary_uom_code
               INTO   l_temp_uom_code
               FROM   mtl_system_items
               WHERE  inventory_item_id = v_lpn_id.inventory_item_id
               AND    organization_id = v_lpn_id.organization_id;

               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Counting an LPN item itself' );
               END IF;

               process_entry ( p_cycle_count_header_id => p_cycle_count_header_id,
                               p_organization_id   => p_organization_id,
                               p_subinventory      => p_subinventory,
                               p_locator_id        => p_locator_id,
                               p_parent_lpn_id     => v_lpn_id.parent_lpn_id,
                               p_inventory_item_id => v_lpn_id.inventory_item_id,
                               p_revision          => v_lpn_id.revision,
                               p_lot_number        => v_lpn_id.lot_number,
                               p_from_serial_number => v_lpn_id.serial_number,
                               p_to_serial_number  => v_lpn_id.serial_number,
                               p_count_quantity    => 1,
                               p_count_uom         => l_temp_uom_code,
                               p_unscheduled_count_entry => p_unscheduled_count_entry,
                               p_user_id           => p_user_id,
                               p_cost_group_id     => v_lpn_id.cost_group_id
                             );
            END IF;
         END IF;

         /* Process the count entries for the LPN content items */
         FOR v_lpn_content IN lpn_contents_cursor
         LOOP
            -- Make sure that this inventory item is defined in the
            -- cycle count header item scope
            SELECT COUNT ( * )
            INTO   l_temp_count
            FROM   mtl_cycle_count_items
            WHERE  inventory_item_id = v_lpn_content.inventory_item_id
            AND    cycle_count_header_id = p_cycle_count_header_id;

            IF ( l_temp_count <> 0 ) THEN
               IF ( l_debug = 1 ) THEN
                  print_debug ( 'Counting an LPN content item' );
               END IF;


        --Bug#4891370.Reduce the loaded quantity from count quantity.
                  OPEN lpn_loaded_quantity_cur(v_lpn_content.inventory_item_id,p_organization_id,l_current_lpn);
                  FETCH lpn_loaded_quantity_cur INTO l_lpn_loaded_qty;

                  IF (lpn_loaded_quantity_cur%FOUND) THEN
                    v_lpn_content.quantity := v_lpn_content.quantity - l_lpn_loaded_qty;
                    IF ( l_debug = 1 ) THEN
                      print_debug ('For lpn_id:'||l_current_lpn||',Loaded qty:'||l_lpn_loaded_qty
                                   ||',count qty:'|| v_lpn_content.quantity  );
                    END IF;
                  END IF;

                  CLOSE lpn_loaded_quantity_cur; ----End of fix for Bug#4891370

               process_entry ( p_cycle_count_header_id => p_cycle_count_header_id,
                               p_organization_id   => p_organization_id,
                               p_subinventory      => p_subinventory,
                               p_locator_id        => p_locator_id,
                               p_parent_lpn_id     => v_lpn_content.parent_lpn_id,
                               p_inventory_item_id => v_lpn_content.inventory_item_id,
                               p_revision          => v_lpn_content.revision,
                               p_lot_number        => v_lpn_content.lot_number,
                               p_from_serial_number => NULL,
                               p_to_serial_number  => NULL,
                               p_count_quantity    => v_lpn_content.quantity,
                               p_count_uom         => v_lpn_content.uom_code,
                               p_unscheduled_count_entry => p_unscheduled_count_entry,
                               p_user_id           => p_user_id,
                               p_cost_group_id     => v_lpn_content.cost_group_id
                             );
            END IF;
         END LOOP;

         /* Process the count entries for serialized items */
         IF ( l_serial_count_option = 2 ) THEN
            -- Single serial
            FOR v_lpn_serial_content IN lpn_serial_contents_cursor
            LOOP
               -- Make sure that this inventory item is defined in the
               -- cycle count header item scope
               SELECT COUNT ( * )
               INTO   l_temp_count
               FROM   mtl_cycle_count_items
               WHERE  inventory_item_id =
                                        v_lpn_serial_content.inventory_item_id
               AND    cycle_count_header_id = p_cycle_count_header_id;

               IF ( l_temp_count <> 0 ) THEN
                  /* Get the primary UOM for the serialized item */
                  SELECT primary_uom_code
                  INTO   l_temp_uom_code
                  FROM   mtl_system_items
                  WHERE  inventory_item_id =
                                        v_lpn_serial_content.inventory_item_id
                  AND    organization_id =
                                  v_lpn_serial_content.current_organization_id;

                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Counting an LPN single serial controlled item'
                                 );
                  END IF;

                  /*
                      ******  Fix for bug 4886188
                      ******  If the Lpn Context is 'Issued Out of Stores' or 'Intransit' or 'Packing Context' or 'Loaded to Dock'
                      ******  count quantity should be taken as 0.
                   */

                    IF ( p_parent_lpn_id IS NOT NULL ) THEN

                       SELECT
                              lpn_context
                       INTO   l_lpn_context
                       FROM   WMS_LICENSE_PLATE_NUMBERS
                       WHERE  lpn_id = p_parent_lpn_id ;

                       IF ( l_debug = 1 ) THEN
                            print_debug ( 'l_lpn_context: => ' || l_lpn_context );
                       END IF;

                       IF l_lpn_context = 8 or l_lpn_context = 9 or l_lpn_context = 4 or l_lpn_context = 6 THEN
                          l_cnt_qty := 0 ;
                       ELSE
                          l_cnt_qty := 1 ;
                       END IF;
                   END IF;
                   /*  End of fix for bug number 4886188 */


                  process_entry ( p_cycle_count_header_id => p_cycle_count_header_id,
                                  p_organization_id   => p_organization_id,
                                  p_subinventory      => p_subinventory,
                                  p_locator_id        => p_locator_id,
                                  p_parent_lpn_id     => v_lpn_serial_content.lpn_id,
                                  p_inventory_item_id => v_lpn_serial_content.inventory_item_id,
                                  p_revision          => v_lpn_serial_content.revision,
                                  p_lot_number        => v_lpn_serial_content.lot_number,
                                  p_from_serial_number => v_lpn_serial_content.serial_number,
                                  p_to_serial_number  => v_lpn_serial_content.serial_number,
                                  p_count_quantity    =>  l_cnt_qty,  --Changed for Bug Number 4886188
                                  p_count_uom         => l_temp_uom_code,
                                  p_unscheduled_count_entry => p_unscheduled_count_entry,
                                  p_user_id           => p_user_id,
                                  p_cost_group_id     => v_lpn_serial_content.cost_group_id
                                );
               END IF;
            END LOOP;
         ELSIF ( l_serial_count_option = 3 ) THEN
            -- Multiple Serial
            FOR v_lpn_multiple_serial IN lpn_multiple_serial_cursor
            LOOP
               -- Make sure that this inventory item is defined in the
               -- cycle count header item scope
               SELECT COUNT ( * )
               INTO   l_temp_count
               FROM   mtl_cycle_count_items
               WHERE  inventory_item_id =
                                       v_lpn_multiple_serial.inventory_item_id
               AND    cycle_count_header_id = p_cycle_count_header_id;

               IF ( l_temp_count <> 0 ) THEN
                  -- Mark all of the serials as present
                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Marking all of the multiple serials as present'
                                 );
                  END IF;

                  inv_cyc_serials.mark_all_present ( p_organization_id   => p_organization_id,
                                                     p_subinventory      => p_subinventory,
                                                     p_locator_id        => p_locator_id,
                                                     p_inventory_item_id => v_lpn_multiple_serial.inventory_item_id,
                                                     p_revision          => v_lpn_multiple_serial.revision,
                                                     p_lot_number        => v_lpn_multiple_serial.lot_number,
                                                     p_cycle_count_header_id => p_cycle_count_header_id,
                                                     p_parent_lpn_id     => v_lpn_multiple_serial.parent_lpn_id
                                                   );

                  IF ( l_debug = 1 ) THEN
                     print_debug ( 'Counting an LPN multiple serial controlled item'
                                 );
                  END IF;

                  process_entry ( p_cycle_count_header_id => p_cycle_count_header_id,
                                  p_organization_id   => p_organization_id,
                                  p_subinventory      => p_subinventory,
                                  p_locator_id        => p_locator_id,
                                  p_parent_lpn_id     => v_lpn_multiple_serial.parent_lpn_id,
                                  p_inventory_item_id => v_lpn_multiple_serial.inventory_item_id,
                                  p_revision          => v_lpn_multiple_serial.revision,
                                  p_lot_number        => v_lpn_multiple_serial.lot_number,
                                  p_from_serial_number => NULL,
                                  p_to_serial_number  => NULL,
                                  p_count_quantity    => NULL,
                                  p_count_uom         => NULL,
                                  p_unscheduled_count_entry => p_unscheduled_count_entry,
                                  p_user_id           => p_user_id,
                                  p_cost_group_id     => v_lpn_multiple_serial.cost_group_id
                                );
               END IF;
            END LOOP;
         END IF;
      END LOOP;
      g_lpn_summary_count := FALSE ; --9452528.
   EXCEPTION
   WHEN OTHERS THEN
     IF ( l_debug = 1 ) THEN
         print_debug ( 'OTHERs Exception' );
      END IF;
     g_lpn_summary_count := FALSE; --9452528
   END process_summary;

   PROCEDURE inv_serial_info (
      p_from_serial_number IN VARCHAR2,
      p_to_serial_number IN VARCHAR2,
      x_prefix    OUT NOCOPY VARCHAR2,
      x_quantity  OUT NOCOPY VARCHAR2,
      x_from_number OUT NOCOPY VARCHAR2,
      x_to_number OUT NOCOPY VARCHAR2,
      x_errorcode OUT NOCOPY NUMBER
   )
   IS
      L_f_alp_part VARCHAR2 ( 30 );
      L_t_alp_part VARCHAR2 ( 30 );
      L_f_num_part VARCHAR2 ( 30 );
      L_t_num_part VARCHAR2 ( 30 );
      L_ser_col_val VARCHAR2 ( 30 );
      L_ser_col_num NUMBER;
      L_from_length NUMBER;
      L_to_length NUMBER;
      L_f_ser_num VARCHAR2 ( 30 );
      L_t_ser_num VARCHAR2 ( 30 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***inv_serial_info***' );
      END IF;

      x_errorcode := 0;
      L_f_ser_num := P_FROM_SERIAL_NUMBER;
      L_t_ser_num := P_TO_SERIAL_NUMBER;
      -- Get the lengths of the two serial numbers. If the to serial
      -- number is not specified copy from serial number to it.
      L_from_length := NVL ( LENGTH ( L_f_ser_num ), 0 );
      L_to_length := NVL ( LENGTH ( L_t_ser_num ), 0 );

      IF ( l_debug = 1 ) THEN
         print_debug ( 'L_from_length=' || L_from_length );
         print_debug ( 'L_to_length=' || L_to_length );
      END IF;

      IF ( L_from_length = 0 ) THEN
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_QTYBTWN_NO_SERIAL' );
         FND_MSG_PUB.ADD;
         x_errorcode := 124;
      END IF;

      IF ( L_to_length = 0 ) THEN
         L_t_ser_num := L_f_ser_num;
         L_to_length := L_from_length;
      END IF;

      -- Split the given serial number into alpha
      -- prefix and numeric part.

      /* From Serial Number */
      L_ser_col_num := L_from_length;

      WHILE ( L_ser_col_num > 0 )
      LOOP
         L_ser_col_val := SUBSTR ( L_f_ser_num, L_ser_col_num, 1 );

         IF ASCII ( L_ser_col_val ) >= 48 AND ASCII ( L_ser_col_val ) <= 57 THEN
            L_f_num_part := L_ser_col_val || L_f_num_part;
         ELSE
            L_f_alp_part := SUBSTR ( L_f_ser_num, 1, L_ser_col_num );
            EXIT;
         END IF;

         L_ser_col_num := L_ser_col_num - 1;
      END LOOP;

      -- To Serial Number
      -- Values for 0 to 9 is corresponds to ASCII value 48 TO 57
      -- All other values are Non-numeric value
      L_ser_col_num := L_to_length;

      WHILE ( L_ser_col_num > 0 )
      LOOP
         L_ser_col_val := SUBSTR ( L_t_ser_num, L_ser_col_num, 1 );

         IF ASCII ( L_ser_col_val ) >= 48 AND ASCII ( L_ser_col_val ) <= 57 THEN
            L_t_num_part := L_ser_col_val || L_t_num_part;
         ELSE
            L_t_alp_part := SUBSTR ( L_t_ser_num, 1, L_ser_col_num );
            EXIT;
         END IF;

         L_ser_col_num := L_ser_col_num - 1;
      END LOOP;

      -- We compare the prefixes to see IF they are the same

      IF    ( L_f_alp_part <> L_t_alp_part )
         OR ( l_f_alp_part IS NULL AND l_t_alp_part IS NOT NULL )
         OR ( l_f_alp_part IS NOT NULL AND l_t_alp_part IS NULL ) THEN
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_QTYBTWN_PFX' );
         FND_MSG_PUB.ADD;
         x_errorcode := 119;
      END IF;

      -- Check the lengths of the two serial numbers to make sure they
      -- match.
      IF ( L_from_length <> L_to_length ) THEN
         -- Message Name : INV_QTYBTWN_LGTH
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_QTYBTWN_LGTH' );
         FND_MSG_PUB.ADD;
         x_errorcode := 120;
      END IF;

      -- Check whether the serial numbers are matched
      -- IF not, check the last character of serial number is character
      -- IF yes, return error message

      -- XXX checks only one
      IF L_f_ser_num <> L_t_ser_num THEN
         IF     ASCII ( SUBSTR ( L_f_ser_num, LENGTH ( L_f_ser_num ), 1 ) ) <
                                                                           48
            AND ASCII ( SUBSTR ( L_f_ser_num, LENGTH ( L_f_ser_num ), 1 ) ) >
                                                                            57 THEN
            FND_MESSAGE.SET_NAME ( 'INV', 'INV_QTYBTWN_LAST' );
            FND_MSG_PUB.ADD;
            x_errorcode := 121;
         END IF;
      END IF;

      -- Calculate the dIFference of serial numbers
      -- How many serial nos are there in the given range
      IF ( l_debug = 1 ) THEN
         print_debug ( 'L_t_num_part=' || L_t_num_part );
         print_debug ( 'L_f_num_part=' || L_f_num_part );
      END IF;

      -- Out variables
      X_Quantity  :=
            NVL ( TO_NUMBER ( L_t_num_part ), 0 )
          - NVL ( TO_NUMBER ( L_f_num_part ), 0 )
          + 1;

      IF ( X_Quantity <= 0 ) THEN
         --  Message Name : INV_QTYBTWN_NUM
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_QTYBTWN_NUM' );
         FND_MSG_PUB.ADD;
         x_errorcode := 122;
      END IF;

      -- Check to make sure To serial number is greater than
      -- From serial number.

      X_PREFIX    := L_f_alp_part;
      X_FROM_NUMBER := L_f_num_part;
      X_TO_NUMBER := L_t_num_part;
   EXCEPTION
      WHEN OTHERS THEN
         x_errorcode := -1;
   END;

   PROCEDURE get_default_cost_group_id (
      p_organization_id IN NUMBER,
      p_subinventory IN VARCHAR2,
      x_out       OUT NOCOPY NUMBER
   )
   IS
      l_default_cost_group_id NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_default_cost_group_id***' );
      END IF;

      BEGIN
         SELECT default_cost_group_id
         INTO   l_default_cost_group_id
         FROM   mtl_secondary_inventories
         WHERE  organization_id = p_organization_id
         AND    secondary_inventory_name = p_subinventory;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_default_cost_group_id := NULL;
      END;

      -- If there is no default at the sub level, get it at the org level
      IF ( l_default_cost_group_id IS NULL ) THEN
         SELECT NVL ( default_cost_group_id, -999 )
         INTO   l_default_cost_group_id
         FROM   mtl_parameters
         WHERE  organization_id = p_organization_id;
      END IF;

      -- Set the out parameters
      x_out       := l_default_cost_group_id;
   END get_default_cost_group_id;

   PROCEDURE get_cost_group_id (
      p_organization_id IN NUMBER,
      p_subinventory IN VARCHAR2,
      p_locator_id IN NUMBER,
      p_parent_lpn_id IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_revision  IN VARCHAR2,
      p_lot_number IN VARCHAR2,
      p_serial_number IN VARCHAR2,
      x_out       OUT NOCOPY NUMBER
   )
   IS
      l_cost_group_id NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_cost_group_id***' );
      END IF;

      IF ( p_serial_number IS NOT NULL ) THEN
         SELECT NVL ( cost_group_id, -999 )
         INTO   l_cost_group_id
         FROM   mtl_serial_numbers
         WHERE  serial_number = p_serial_number
         AND    inventory_item_id = p_inventory_item_id
         AND    NVL ( revision, '@@@@@' ) = NVL ( p_revision, '@@@@@' )
         AND    NVL ( lot_number, '@@@@@' ) = NVL ( p_lot_number, '@@@@@' )
         AND    current_organization_id = p_organization_id
         --AND current_subinventory_code = p_subinventory
         --AND NVL(current_locator_id, -99999) = NVL(p_locator_id, -99999)
         AND    NVL ( lpn_id, -99999 ) = NVL ( p_parent_lpn_id, -99999 );
      ELSIF ( p_parent_lpn_id IS NOT NULL ) THEN
      BEGIN
         SELECT DISTINCT NVL ( cost_group_id, -999 ) --bug3687177
         INTO   l_cost_group_id
         FROM   wms_lpn_contents
         WHERE  parent_lpn_id = p_parent_lpn_id
         AND    organization_id = p_organization_id
         AND    inventory_item_id = p_inventory_item_id
         AND    NVL ( revision, '@@@@@' ) = NVL ( p_revision, '@@@@@' )
         AND    NVL ( lot_number, '@@@@@' ) = NVL ( p_lot_number, '@@@@@' )
         AND    NVL ( serial_summary_entry, 2 ) = 2;
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
           IF ( l_debug = 1 ) THEN
               print_debug ( 'Too many rows returned in call to get_cost_group_id');
           END IF;
      END;
      ELSE
         SELECT DISTINCT NVL ( cost_group_id, -999 )
         INTO            l_cost_group_id
         FROM            MTL_ONHAND_QUANTITIES_DETAIL
         WHERE           inventory_item_id = p_inventory_item_id
         AND             NVL ( revision, '@@@@@' ) =
                                                   NVL ( p_revision, '@@@@@' )
         AND             NVL ( lot_number, '@@@@@' ) =
                                                 NVL ( p_lot_number, '@@@@@' )
         AND             organization_id = p_organization_id
         AND             subinventory_code = p_subinventory
         AND             NVL ( locator_id, -99999 ) =
                                                   NVL ( p_locator_id, -99999 )
         AND             NVL ( containerized_flag, 2 ) = 2;
      END IF;

      -- Set the out return variable
      x_out       := l_cost_group_id;
   EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Too many rows returned in call to get_cost_group_id'
                        );
         END IF;

         x_out       := -999;
      WHEN NO_DATA_FOUND THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'No cost group found for this item' );
         END IF;

         x_out       := -999;
   END get_cost_group_id;

   PROCEDURE ok_proc
   IS
      tmp_count NUMBER;
      serial_pos_adj_count NUMBER;
      serial_neg_adj_count NUMBER;
      cur_rec   NUMBER;

      CURSOR cc_multiple_entry_cursor
      IS
         SELECT *
         FROM   mtl_cc_serial_numbers
         WHERE  cycle_count_entry_id = g_cc_entry.cycle_count_entry_id;

      l_group_mark_id NUMBER;
      l_serial_adjustment_option NUMBER;
      l_approval_tolerance_positive NUMBER;
      l_approval_tolerance_negative NUMBER;
      l_cost_tolerance_positive NUMBER;
      l_cost_tolerance_negative NUMBER;
      l_number_of_counts NUMBER;
      l_unit_status NUMBER;
      l_num_counts NUMBER := g_cc_entry.number_of_counts;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      --Bug 5186993
      l_automatic_recount_flag NUMBER;
      l_maximum_auto_recounts  NUMBER;
      l_days_until_late        NUMBER;
      --Bug 6978840
      l_approval_option_code   NUMBER;

   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***ok_proc***' );
      END IF;

      tmp_count   := 0;
      g_serial_out_tolerance := FALSE;
      -- There is never a positive serial adjustment since
      -- new serials will never be counted in mobile multiple
      -- serial counting.  That is not being allowed at this time.
      serial_pos_adj_count := 0;
      serial_neg_adj_count := 0;
      g_count_entry_status_code := g_cc_entry.entry_status_code;
      OPEN cc_multiple_entry_cursor;

      LOOP
         -- Note that here, all we are doing is calculating the values for
         -- serial_pos_adj_count, serial_neg_adj_count, and tmp_count in this loop.
         FETCH cc_multiple_entry_cursor INTO g_cc_serial_entry;
         EXIT WHEN cc_multiple_entry_cursor%NOTFOUND;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Current serial processing: '
                          || g_cc_serial_entry.serial_number
                        );
         END IF;

         -- For each multiple serial entry, get the
         -- serial number's group mark ID to determine if it was
         -- counted as present or not
         SELECT group_mark_id
         INTO   l_group_mark_id
         FROM   mtl_serial_numbers
         WHERE  serial_number = g_cc_serial_entry.serial_number
         AND    current_organization_id = g_cc_entry.organization_id
         AND    inventory_item_id = g_cc_entry.inventory_item_id;

         IF ( l_group_mark_id = 1 ) THEN
            -- We can not count the serial number towards the total count
            -- if the serial number was marked as not present.
            tmp_count   := tmp_count + 1;
            l_unit_status := 1;
         ELSE
            l_unit_status := 2;
         END IF;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Serial status for: '
                          || g_cc_serial_entry.serial_number
                          || ' = '
                          || l_unit_status
                        );
         END IF;

         -- Find out the number of serial numbers user claims as missing and also
         -- find out the number of new serial numbers user finds during the count
         -- Note that in mobile multiple cycle counting, we are currently NOT
         -- allowing unscheduled multiple serial entries
         IF (     ( g_cc_serial_entry.unit_status_current <>
                                           g_cc_serial_entry.unit_status_prior
                  )
              OR ( g_cc_serial_entry.unit_status_first IS NULL )
            ) THEN
            -- Since we do not allow new multiple serials to be found yet for
            -- mobile, serial_pos_adj_count will always be the initial value of
            -- 0.  If this serial entry was new, then we would increment
            -- the parameter serial_pos_adj_count
            IF ( l_unit_status = 2 ) THEN
               serial_neg_adj_count := serial_neg_adj_count - 1;
            END IF;
         END IF;

         -- Update the multiple serial info
         -- Modified the following for the Bug 4564346
         --l_number_of_counts := NVL ( g_cc_serial_entry.number_of_counts, 0 ) + 1;
         l_number_of_counts := NVL ( g_cc_serial_entry.number_of_counts,1);

         IF ( l_number_of_counts = 1 ) THEN
            -- First count
            g_cc_serial_entry.unit_status_current := l_unit_status;
            g_cc_serial_entry.unit_status_first := l_unit_status;
         ELSIF ( l_number_of_counts > 1 ) THEN
            g_cc_serial_entry.unit_status_prior :=
                                        g_cc_serial_entry.unit_status_current;
            g_cc_serial_entry.unit_status_current := l_unit_status;
         END IF;

         -- Following condition will only be true for new
         -- serial numbers created at the recount stage.
         IF ( l_number_of_counts <= l_num_counts ) THEN
            l_number_of_counts := l_num_counts + 1;
         END IF;

         g_cc_serial_entry.number_of_counts := l_number_of_counts;
      END LOOP;

      CLOSE cc_multiple_entry_cursor;
      -- Set the global count and UOM values for multiple serials
      -- since this is not initially set
      g_count_quantity := tmp_count;

      SELECT primary_uom_code
      INTO   g_count_uom
      FROM   mtl_system_items
      WHERE  inventory_item_id = g_cc_entry.inventory_item_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the serial adjustment option for the cycle count header
      -- Bug 5186993
      SELECT NVL ( serial_adjustment_option, 2 ), NVL ( automatic_recount_flag, 2 ),
             NVL ( maximum_auto_recounts, 0 ), NVL ( days_until_late , 0 ),
             --Bug 6978840
             NVL( approval_option_code , 3)
      INTO   l_serial_adjustment_option, l_automatic_recount_flag, l_maximum_auto_recounts, l_days_until_late, l_approval_option_code
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id;

      -- The user has selected 'Adjust if Possible' option for the serial items
      IF ( l_debug = 1 ) THEN
         print_debug (    'Multiple serial adjustment option: '
                       || l_serial_adjustment_option
                     );
      END IF;

      IF ( l_serial_adjustment_option <> 2 ) THEN
         -- Populate appropriate cycle count level tolerance information
         get_tolerances ( pre_approve_flag    => 'SERIAL',
                          x_approval_tolerance_positive => l_approval_tolerance_positive,
                          x_approval_tolerance_negative => l_approval_tolerance_negative,
                          x_cost_tolerance_positive => l_cost_tolerance_positive,
                          x_cost_tolerance_negative => l_cost_tolerance_negative
                        );

         -- If user found new serial numbers during his counting then find out
         -- if total number of new serial numbers are within allowable tolerance or not.
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial Pos Adj Count: ' || serial_pos_adj_count );
         END IF;

         IF ( serial_pos_adj_count <> 0 ) THEN
            serial_tolerance_logic ( p_serial_adj_qty    => serial_pos_adj_count,
                                     p_app_tol_pos       => l_approval_tolerance_positive,
                                     p_app_tol_neg       => l_approval_tolerance_negative,
                                     p_cost_tol_pos      => l_cost_tolerance_positive,
                                     p_cost_tol_neg      => l_cost_tolerance_negative
                                   );
         END IF;

         -- If user found some serial numbers missing and we are still within
         -- adjustment tolerance then find out if we are within allowable
         -- negative tolerance or not.
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial Neg Adj Count: ' || serial_neg_adj_count );
         END IF;

         IF ( serial_neg_adj_count <> 0 AND g_serial_out_tolerance = FALSE ) THEN
            serial_tolerance_logic ( p_serial_adj_qty    => serial_neg_adj_count,
                                     p_app_tol_pos       => l_approval_tolerance_positive,
                                     p_app_tol_neg       => l_approval_tolerance_negative,
                                     p_cost_tol_pos      => l_cost_tolerance_positive,
                                     p_cost_tol_neg      => l_cost_tolerance_negative
                                   );
         END IF;
      END IF;

      -- For existing records
      IF ( l_debug = 1 ) THEN
         print_debug ( 'Looping again for multiple existing serial entries' );
      END IF;

      OPEN cc_multiple_entry_cursor;

      LOOP
         FETCH cc_multiple_entry_cursor INTO g_cc_serial_entry;
         EXIT WHEN cc_multiple_entry_cursor%NOTFOUND;

         -- For each multiple serial entry, get the
         -- serial number's group mark ID to determine if it was
         -- counted as present or not.  We have to do this again since
         -- the updating in the same cursor used previously does not save
         -- and we do not want to necessarily do a commit yet.
         SELECT group_mark_id
         INTO   l_group_mark_id
         FROM   mtl_serial_numbers
         WHERE  serial_number = g_cc_serial_entry.serial_number
         AND    current_organization_id = g_cc_entry.organization_id
         AND    inventory_item_id = g_cc_entry.inventory_item_id;

         IF ( l_group_mark_id = 1 ) THEN
            l_unit_status := 1;
         ELSE
            l_unit_status := 2;
         END IF;

         -- Update the multiple serial info
         l_number_of_counts :=
                                 NVL ( g_cc_serial_entry.number_of_counts, 0 )
                               + 1;

         IF ( l_number_of_counts = 1 ) THEN
            -- First count
            g_cc_serial_entry.unit_status_current := l_unit_status;
            g_cc_serial_entry.unit_status_first := l_unit_status;
         ELSIF ( l_number_of_counts > 1 ) THEN
            g_cc_serial_entry.unit_status_prior :=
                                        g_cc_serial_entry.unit_status_current;
            g_cc_serial_entry.unit_status_current := l_unit_status;
         END IF;

         -- Following condition will only be true for new serial numbers
         -- created at the recount stage.
         IF ( l_number_of_counts <= l_num_counts ) THEN
            l_number_of_counts := l_num_counts + 1;
         END IF;

         -- Update the number of counts
         g_cc_serial_entry.number_of_counts := l_number_of_counts;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Serial number processed: '
                          || g_cc_serial_entry.serial_number
                        );
            print_debug (    'number of counts: '
                          || g_cc_serial_entry.number_of_counts
                        );
            print_debug (    'current status: '
                          || g_cc_serial_entry.unit_status_current
                        );
            print_debug (    'prior status: '
                          || g_cc_serial_entry.unit_status_prior
                        );
            print_debug (    'first status: '
                          || g_cc_serial_entry.unit_status_first
                        );
         END IF;

         IF ( g_cc_serial_entry.unit_status_current =
                              NVL ( g_cc_serial_entry.unit_status_prior, -999 )
            ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Status of serial is unchanged' );
            END IF;

            g_serial_entry_status_code := 5;
            count_entry_status_code ( );
            update_serial_row ( );
         ELSIF ( g_cc_serial_entry.unit_status_current <>
                              NVL ( g_cc_serial_entry.unit_status_prior, -999 )
               ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'Status of serial has changed since last counted'
                           );
            END IF;

            -- Dont need to mark the serial since the serial has already
            -- been marked with a group mark ID of 1 if it was counted as
            -- present for multiple serial count option.  I'm also assuming
            -- that if the serial is unmarked, it will have a null value or
            -- non-positive value for the group mark ID for that serial number
            --mark();
            existing_serial_number ( );
            count_entry_status_code ( );
            update_serial_row ( );
         END IF;

         -- Bug# 2379201
         -- If the serial was counted as present, then we should unmark the
         -- serial here since we don't need that information anymore.
         -- The group mark ID was marked with a value of 1 only to indicate
         -- that it was present and so no adjustment needs to be made for that
         -- serial.  Therefore there is no need to mark it.
         IF ( g_cc_serial_entry.unit_status_current = 1 ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug (    'Unmarking the serial found present: '
                             || g_cc_serial_entry.serial_number
                           );
            END IF;

            UPDATE mtl_serial_numbers
            SET group_mark_id = NULL
            WHERE  serial_number = g_cc_serial_entry.serial_number
            AND    current_organization_id = g_cc_entry.organization_id
            AND    inventory_item_id = g_cc_entry.inventory_item_id;
         END IF;
      END LOOP;

      CLOSE cc_multiple_entry_cursor;

      -- This is based on the assumption that only Approver can request a recount in case of
      -- Multiple Serial Number per count. In that case after recount is done and no changes
      -- are made, we need to send the count back for approval.
      IF ( g_count_entry_status_code = 3 ) THEN
         g_count_entry_status_code := 2;
      END IF;

        IF ( l_debug = 1 ) THEN
           print_debug ( 'l_automatic_recount_flag = '||l_automatic_recount_flag||', g_cc_entry.number_of_counts = '||g_cc_entry.number_of_counts||', l_maximum_auto_recounts = '||l_maximum_auto_recounts);
         END IF;

         -- Bug 5186993, if automatic recount is set, check whether the adjustment has been
         -- counted the maximum number of times, if not setting for recount
         -- Bug 6978840 , checking if the approval option is 'If out of tolerance' and tolerance is not met
    if(l_approval_option_code = 3 and g_serial_out_tolerance = TRUE  ) then
         if ( l_automatic_recount_flag = 1 AND nvl(g_cc_entry.number_of_counts, 0) < l_maximum_auto_recounts ) THEN
                IF ( l_debug = 1 ) THEN
                   print_debug ( 'ok_proc: Setting to recount' );
                END IF;
                g_count_entry_status_code := 3;
                g_cc_entry.count_due_date := SYSDATE + l_days_until_late;
         end if;
    end if;

      get_final_count_info ( );
   END ok_proc;

   PROCEDURE serial_tolerance_logic (
      p_serial_adj_qty IN NUMBER,
      p_app_tol_pos IN NUMBER,
      p_app_tol_neg IN NUMBER,
      p_cost_tol_pos IN NUMBER,
      p_cost_tol_neg IN NUMBER
   )
   IS
      l_system_quantity NUMBER;
      l_adjustment_value NUMBER;
      l_approval_option_code NUMBER;
      l_item_cost NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***serial_tolerance_logic***' );
      END IF;

      -- Get the cycle count headers approval option code
      SELECT NVL ( approval_option_code, 1 )
      INTO   l_approval_option_code
      FROM   mtl_cycle_count_headers
      WHERE  cycle_count_header_id = g_cc_entry.cycle_count_header_id
      AND    organization_id = g_cc_entry.organization_id;

      -- Get the system quantity
      system_quantity ( x_system_quantity => l_system_quantity );
      g_serial_out_tolerance := FALSE;
      -- Get the item cost
      l_item_cost :=
         get_item_cost ( in_org_id           => g_cc_entry.organization_id,
                         in_item_id          => g_cc_entry.inventory_item_id,
                         in_locator_id       => g_cc_entry.locator_id
                       );
      g_cc_entry.item_unit_cost := l_item_cost;
      -- Calculate the adjustment value
      l_adjustment_value := l_item_cost * p_serial_adj_qty;

      IF ( l_debug = 1 ) THEN
            print_debug ( 'Value : l_system_quantity ' || l_system_quantity );
            print_debug ( 'Value : p_serial_adj_qty ' || p_serial_adj_qty );
            print_debug ( 'Value : p_app_tol_neg ' || p_app_tol_neg );
            print_debug ( 'Value : p_cost_tol_neg ' || p_cost_tol_neg );
            print_debug ( 'Value : p_app_tol_pos ' || p_app_tol_pos );
      END IF;


      IF ( l_approval_option_code = 1 ) THEN
         -- Approval_option = always
         g_serial_out_tolerance := TRUE;
      ELSIF ( l_approval_option_code = 2 ) THEN
         -- Approval option = never
         g_serial_out_tolerance := FALSE;
      ELSE
         -- Approval option = required if out of tolerance
         IF ( l_system_quantity <> 0 ) THEN
            IF ( p_serial_adj_qty < 0 ) THEN
               IF (      ( p_app_tol_neg IS NOT NULL and p_app_tol_neg <> -1 ) /* added -1 constraint for bug 4926279 */
                    AND ( ABS (  ( p_serial_adj_qty / l_system_quantity )
                                * 100 ) > p_app_tol_neg
                        )
                  ) THEN
                  g_serial_out_tolerance := TRUE;
               ELSE
                  IF (      ( p_cost_tol_neg IS NOT NULL and p_cost_tol_neg <> -1 )  /* added -1 constraint for bug 4926279 */
                       AND ( ABS ( l_adjustment_value ) > p_cost_tol_neg )
                     ) THEN
                     g_serial_out_tolerance := TRUE;
                  ELSE
                     g_serial_out_tolerance := FALSE;
                  END IF;
               END IF;
            ELSE -- p_serial_adj_qty >= 0
               IF (      ( p_app_tol_pos IS NOT NULL  and p_app_tol_pos <> -1)   /* added -1 constraint for bug 4926279 */
                    AND ( ABS (  ( p_serial_adj_qty / l_system_quantity )
                                * 100 ) > p_app_tol_pos
                        )
                  ) THEN
                  g_serial_out_tolerance := TRUE;
               ELSE
                  IF (     p_cost_tol_pos IS NOT NULL  and p_cost_tol_pos <> -1    /* added -1 constraint for bug 4926279 */
                       AND ( ABS ( l_adjustment_value ) > p_cost_tol_pos )
                     ) THEN
                     g_serial_out_tolerance := TRUE;
                  ELSE
                     g_serial_out_tolerance := FALSE;
                  END IF;
               END IF;
            END IF;
         ELSE -- system quantity = 0
            IF ( p_app_tol_pos IS NOT NULL and p_app_tol_pos <> -1) THEN    /* added -1 constraint for bug 4926279 */
               g_serial_out_tolerance := TRUE;
            ELSE
               IF (      ( p_cost_tol_pos IS NOT NULL  and p_cost_tol_pos <> -1)  /* added -1 constraint for bug 4926279 */
                    AND ( l_adjustment_value > p_cost_tol_pos )
                  ) THEN
                  g_serial_out_tolerance := TRUE;
               ELSE
                  g_serial_out_tolerance := FALSE;
               END IF;
            END IF;
         END IF;
      END IF;

      IF ( g_serial_out_tolerance ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'g_serial_out_tolerance: TRUE' );
         END IF;
      ELSE
         IF ( l_debug = 1 ) THEN
            print_debug ( 'g_serial_out_tolerance: FALSE' );
         END IF;
      END IF;
   END serial_tolerance_logic;

   PROCEDURE get_final_count_info
   IS
      l_entry_status_code NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_final_count_info***' );
      END IF;

      g_cc_entry.entry_status_code := g_count_entry_status_code;
      l_entry_status_code := g_cc_entry.entry_status_code;

      IF ( l_entry_status_code = 5 ) THEN
         -- Count complete
         g_cc_entry.approval_date := SYSDATE;
      END IF;
   END get_final_count_info;

   PROCEDURE get_scheduled_entry (
      p_cycle_count_header_id IN NUMBER,
      x_count     OUT NOCOPY NUMBER
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_scheduled_entry***' );
      END IF;

      SELECT COUNT ( * )
      INTO   x_count
      FROM   mtl_cycle_count_entries
      WHERE  cycle_count_header_id = p_cycle_count_header_id
      AND    entry_status_code IN ( 1, 3 )
      AND    NVL ( export_flag, 2 ) = 2;
   END get_scheduled_entry;

-- This is a wrapper to call inventory INV_LOT_API_PUB.insertLot
-- it stores the inserted lot info in a global variable for
-- transaction exception rollback
   PROCEDURE insert_dynamic_lot (
      p_api_version IN NUMBER,
      p_init_msg_list IN VARCHAR2,
      p_commit    IN VARCHAR2,
      p_validation_level IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_lot_number IN VARCHAR2,
      p_expiration_date IN OUT NOCOPY DATE,
      p_transaction_temp_id IN NUMBER,
      p_transaction_action_id IN NUMBER,
      p_transfer_organization_id IN NUMBER,
      p_status_id IN NUMBER,
      p_update_status IN VARCHAR2,
      x_object_id OUT NOCOPY NUMBER,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data  OUT NOCOPY VARCHAR2
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      -- Initialize the return status
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( l_debug = 1 ) THEN
         print_debug ( '***Calling insert_dynamic_lot***' );
      END IF;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'Calling insertlot' );
      END IF;

      inv_lot_api_pub.insertlot ( p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => p_validation_level,
                                  p_inventory_item_id => p_inventory_item_id,
                                  p_organization_id   => p_organization_id,
                                  p_lot_number        => p_lot_number,
                                  p_expiration_date   => p_expiration_date,
                                  p_transaction_temp_id => p_transaction_temp_id,
                                  p_transaction_action_id => p_transaction_action_id,
                                  p_transfer_organization_id => p_transfer_organization_id,
                                  x_object_id         => x_object_id,
                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data
                                );

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'insertLot was not called successfully' );
         END IF;

         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'insertLot was called successfully' );
      END IF;

      IF (      ( x_return_status = FND_API.g_ret_sts_success )
           AND ( p_update_status = 'TRUE' )
         ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Update the status of the new lot' );
         END IF;

         inv_material_status_grp.update_status ( p_api_version_number => p_api_version,
                                                 p_init_msg_lst      => NULL,
                                                 x_return_status     => x_return_status,
                                                 x_msg_count         => x_msg_count,
                                                 x_msg_data          => x_msg_data,
                                                 p_update_method     => inv_material_status_pub.g_update_method_receive,
                                                 p_status_id         => p_status_id,
                                                 p_organization_id   => p_organization_id,
                                                 p_inventory_item_id => p_inventory_item_id,
                                                 p_sub_code          => NULL,
                                                 p_locator_id        => NULL,
                                                 p_lot_number        => p_lot_number,
                                                 p_serial_number     => NULL,
                                                 p_to_serial_number  => NULL,
                                                 p_object_type       => 'O'
                                               );

         IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'update_status was not called successfully' );
            END IF;

            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END insert_dynamic_lot;

   PROCEDURE update_serial_status (
      p_api_version IN NUMBER,
      p_init_msg_list IN VARCHAR2,
      p_commit    IN VARCHAR2,
      p_validation_level IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_from_serial_number IN VARCHAR2,
      p_to_serial_number IN VARCHAR2,
      p_current_status IN NUMBER,
      p_serial_status_id IN NUMBER,
      p_update_serial_status IN VARCHAR2,
      p_lot_number IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data  OUT NOCOPY VARCHAR2
   )
   IS
      l_from_ser_number NUMBER;
      l_to_ser_number NUMBER;
      l_range_numbers NUMBER;
      l_temp_prefix VARCHAR2 ( 30 );
      l_cur_serial_number VARCHAR2 ( 30 );
      l_cur_ser_number NUMBER;
      l_serial_num_length NUMBER;
      l_prefix_length NUMBER;
      l_progress VARCHAR2 ( 10 );
      l_success NUMBER;
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug (    'Enter update_serial_status: 10:'
                       || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                     );
      END IF;

      l_progress  := '10';
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      SAVEPOINT count_update_serial_sp;
      l_progress  := '20';
      -- get the number part of the 'to' serial
      inv_validate.number_from_sequence ( p_to_serial_number,
                                          l_temp_prefix,
                                          l_to_ser_number
                                        );
      l_progress  := '30';
      -- get the number part of the 'from' serial
      inv_validate.number_from_sequence ( p_from_serial_number,
                                          l_temp_prefix,
                                          l_from_ser_number
                                        );
      l_progress  := '40';
      -- total number of serials inserted into mtl_serial_numbers
      l_range_numbers := l_to_ser_number - l_from_ser_number + 1;
      l_serial_num_length := LENGTH ( p_from_serial_number );
      l_prefix_length := LENGTH ( l_temp_prefix );

      FOR i IN 1 .. l_range_numbers
      LOOP
         l_cur_ser_number := l_from_ser_number + i - 1;
         -- concatenate the serial number to be inserted
         l_cur_serial_number :=
                l_temp_prefix
             || LPAD ( l_cur_ser_number,
                        l_serial_num_length - l_prefix_length,
                       '0'
                     );
         l_progress  := '50';

         UPDATE mtl_serial_numbers
         SET previous_status = current_status,
             current_status = p_current_status,
             lot_number = p_lot_number,
             current_organization_id = p_organization_id
         WHERE  serial_number = l_cur_serial_number
         AND    inventory_item_id = p_inventory_item_id;

         l_progress  := '60';

         IF p_update_serial_status = 'TRUE' THEN
            l_progress  := '70';
            inv_material_status_grp.update_status ( p_api_version_number => p_api_version,
                                                    p_init_msg_lst      => NULL,
                                                    x_return_status     => x_return_status,
                                                    x_msg_count         => x_msg_count,
                                                    x_msg_data          => x_msg_data,
                                                    p_update_method     => inv_material_status_pub.g_update_method_receive,
                                                    p_status_id         => p_serial_status_id,
                                                    p_organization_id   => p_organization_id,
                                                    p_inventory_item_id => p_inventory_item_id,
                                                    p_sub_code          => NULL,
                                                    p_locator_id        => NULL,
                                                    p_lot_number        => p_lot_number,
                                                    p_serial_number     => l_cur_serial_number,
                                                    p_to_serial_number  => NULL,
                                                    p_object_type       => 'S'
                                                  );
         END IF;

         l_progress  := '80';

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      l_progress  := '90';
      serial_check.inv_mark_serial ( from_serial_number  => p_from_serial_number,
                                     to_serial_number    => p_to_serial_number,
                                     item_id             => p_inventory_item_id,
                                     org_id              => p_organization_id,
                                     hdr_id              => NULL,
                                     temp_id             => NULL,
                                     lot_temp_id         => NULL,
                                     success             => l_success
                                   );
      l_progress  := '100';

      IF ( l_debug = 1 ) THEN
         print_debug (    'Exit update_serial_status 110:'
                       || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                     );
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO count_update_serial_sp;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exitting update_serial_status - execution error:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;

         --  Get message count and data
         fnd_msg_pub.count_and_get ( p_encoded           => fnd_api.g_false,
                                     p_count             => x_msg_count,
                                     p_data              => x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO count_update_serial_sp;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exitting update_serial_status - unexpected error:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;

         --  Get message count and data
         fnd_msg_pub.count_and_get ( p_encoded           => fnd_api.g_false,
                                     p_count             => x_msg_count,
                                     p_data              => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO count_update_serial_sp;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exitting update_serial_status - other exceptions:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;

         IF SQLCODE IS NOT NULL THEN
            inv_mobile_helper_functions.sql_error ( 'INV_RCV_COMMON_APIS.update_serial_status',
                                                    l_progress,
                                                    SQLCODE
                                                  );
         END IF;

         IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
            fnd_msg_pub.add_exc_msg ( g_pkg_name, 'update_serial_status' );
         END IF;

         --  Get message count and data
         fnd_msg_pub.count_and_get ( p_encoded           => fnd_api.g_false,
                                     p_count             => x_msg_count,
                                     p_data              => x_msg_data
                                   );
   END update_serial_status;

-- This is a wrapper to call inventory insert_range_serial
   PROCEDURE insert_range_serial (
      p_api_version IN NUMBER,
      p_init_msg_list IN VARCHAR2,
      p_commit    IN VARCHAR2,
      p_validation_level IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_from_serial_number IN VARCHAR2,
      p_to_serial_number IN VARCHAR2,
      p_revision  IN VARCHAR2,
      p_lot_number IN VARCHAR2,
      p_current_status IN NUMBER,
      p_serial_status_id IN NUMBER,
      p_update_serial_status IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data  OUT NOCOPY VARCHAR2
   )
   IS
      l_object_id NUMBER;
      l_success NUMBER;
      l_progress VARCHAR2 ( 10 );
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug (    'Enter insert_range_serial: 10:'
                       || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                     );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_progress  := '10';
      SAVEPOINT count_insert_range_serial_sp;
      l_progress  := '20';
      inv_serial_number_pub.insert_range_serial ( p_api_version       => p_api_version,
                                                  p_init_msg_list     => p_init_msg_list,
                                                  p_commit            => p_commit,
                                                  p_validation_level  => p_validation_level,
                                                  p_inventory_item_id => p_inventory_item_id,
                                                  p_organization_id   => p_organization_id,
                                                  p_from_serial_number => p_from_serial_number,
                                                  p_to_serial_number  => p_to_serial_number,
                                                  p_initialization_date => SYSDATE,
                                                  p_completion_date   => NULL,
                                                  p_ship_date         => NULL,
                                                  p_revision          => p_revision,
                                                  p_lot_number        => p_lot_number,
                                                  p_current_locator_id => NULL,
                                                  p_subinventory_code => NULL,
                                                  p_trx_src_id        => NULL,
                                                  p_unit_vendor_id    => NULL,
                                                  p_vendor_lot_number => NULL,
                                                  p_vendor_serial_number => NULL,
                                                  p_receipt_issue_type => NULL,
                                                  p_txn_src_id        => NULL,
                                                  p_txn_src_name      => NULL,
                                                  p_txn_src_type_id   => NULL,
                                                  p_transaction_id    => NULL,
                                                  p_current_status    => p_current_status,
                                                  p_parent_item_id    => NULL,
                                                  p_parent_serial_number => NULL,
                                                  p_cost_group_id     => NULL,
                                                  p_transaction_action_id => NULL,
                                                  p_transaction_temp_id => NULL,
                                                  p_status_id         => NULL,
                                                  p_inspection_status => NULL,
                                                  x_object_id         => l_object_id,
                                                  x_return_status     => x_return_status,
                                                  x_msg_count         => x_msg_count,
                                                  x_msg_data          => x_msg_data
                                                );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         FND_MESSAGE.SET_NAME ( 'INV', 'INV_LOT_COMMIT_FAILURE' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_progress  := '30';

      IF p_update_serial_status = 'TRUE' THEN
         l_progress  := '40';
         inv_material_status_grp.update_status ( p_api_version_number => p_api_version,
                                                 p_init_msg_lst      => NULL,
                                                 x_return_status     => x_return_status,
                                                 x_msg_count         => x_msg_count,
                                                 x_msg_data          => x_msg_data,
                                                 p_update_method     => inv_material_status_pub.g_update_method_receive,
                                                 p_status_id         => p_serial_status_id,
                                                 p_organization_id   => p_organization_id,
                                                 p_inventory_item_id => p_inventory_item_id,
                                                 p_sub_code          => NULL,
                                                 p_locator_id        => NULL,
                                                 p_lot_number        => p_lot_number,
                                                 p_serial_number     => p_from_serial_number,
                                                 p_to_serial_number  => p_to_serial_number,
                                                 p_object_type       => 'S'
                                               );
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_progress  := '50';
      serial_check.inv_mark_serial ( from_serial_number  => p_from_serial_number,
                                     to_serial_number    => p_to_serial_number,
                                     item_id             => p_inventory_item_id,
                                     org_id              => p_organization_id,
                                     hdr_id              => NULL,
                                     temp_id             => NULL,
                                     lot_temp_id         => NULL,
                                     success             => l_success
                                   );
      l_progress  := '60';

      IF ( l_debug = 1 ) THEN
         print_debug (    'Exit insert_range_serial 90:'
                       || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                     );
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO count_insert_range_serial_sp;
         x_return_status := fnd_api.g_ret_sts_error;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exitting insert_range_serial - execution error:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;

         --  Get message count and data
         fnd_msg_pub.count_and_get ( p_encoded           => fnd_api.g_false,
                                     p_count             => x_msg_count,
                                     p_data              => x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO count_insert_range_serial_sp;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exitting insert_range_serial - unexpected error:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --  Get message count and data
         fnd_msg_pub.count_and_get ( p_encoded           => fnd_api.g_false,
                                     p_count             => x_msg_count,
                                     p_data              => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO count_insert_range_serial_sp;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exitting insert_range_serial - other exceptions:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF SQLCODE IS NOT NULL THEN
            inv_mobile_helper_functions.sql_error ( 'INV_RCV_COMMON_APIS.insert_range_serial',
                                                    l_progress,
                                                    SQLCODE
                                                  );
         END IF;

         IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
            fnd_msg_pub.add_exc_msg ( g_pkg_name, 'insert_range_serial' );
         END IF;

         --  Get message count and data
         fnd_msg_pub.count_and_get ( p_encoded           => fnd_api.g_false,
                                     p_count             => x_msg_count,
                                     p_data              => x_msg_data
                                   );
   END insert_range_serial;

   PROCEDURE get_system_quantity (
      p_organization_id IN NUMBER,
      p_subinventory IN VARCHAR2,
      p_locator_id IN NUMBER,
      p_parent_lpn_id IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_revision  IN VARCHAR2,
      p_lot_number IN VARCHAR2,
      p_uom_code  IN VARCHAR2,
      x_system_quantity OUT NOCOPY NUMBER
   )
   IS
      l_primary_uom VARCHAR2 ( 3 );
      l_serial_number_control_code NUMBER;
      l_progress VARCHAR2 ( 10 );
      l_converted_quantity NUMBER;
      l_loaded_sys_qty NUMBER; -- bug 2640378
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

      /* Bug 4886188 -Added the local variables for the lpn details from wlpn*/
       l_lpn_subinv  VARCHAR2(10) ;
       l_lpn_locator_id  NUMBER ;
       l_lpn_context  NUMBER;
      /* End of fix for Bug 4886188 */
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***get_system_quantity***' );
      END IF;

      -- Initialize the output variable
      x_system_quantity := 0;
      l_progress  := '10';

         /*
              ******  Fix for bug 4886188
              ******  If the Lpn Context is 'Issued Out of Stores' or 'Intransit' or 'Packing Context' or 'Loaded to Dock'
              ******  system quantity should be shown as 0. Because, ideally the LPN will not be present in that location.
           */

            IF ( p_parent_lpn_id IS NOT NULL ) THEN

               SELECT NVL ( subinventory_code, '###' ),
                      NVL ( locator_id, -99 ),
                      lpn_context
               INTO   l_lpn_subinv,
                      l_lpn_locator_id,
                      l_lpn_context
               FROM   WMS_LICENSE_PLATE_NUMBERS
               WHERE  lpn_id = p_parent_lpn_id ;

               IF ( l_debug = 1 ) THEN
                    print_debug ( 'l_lpn_subinv: ===> ' || l_lpn_subinv );
                    print_debug ( 'l_lpn_locator_id: => ' || l_lpn_locator_id );
                    print_debug ( 'l_lpn_context: => ' || l_lpn_context );
               END IF;

               IF l_lpn_context = 8 or l_lpn_context = 9 or l_lpn_context = 4 or l_lpn_context = 6 THEN
                  IF ( l_debug = 1 ) THEN
                    print_debug ( 'Returning the system quantity as 0' );
                  END IF;
                  g_condition:=TRUE ;
                  return;
               END IF;
           END IF;
           /*  End of fix for bug number 4886188 */



      SELECT primary_uom_code,
             serial_number_control_code
      INTO   l_primary_uom,
             l_serial_number_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_inventory_item_id
      AND    organization_id = p_organization_id;

      l_progress  := '20';

      IF ( l_serial_number_control_code IN ( 1, 6 ) ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Non serial controlled item' );
         END IF;

         IF ( p_parent_lpn_id IS NULL ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is null' );
            END IF;

            SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
            INTO   x_system_quantity
            FROM   MTL_ONHAND_QUANTITIES_DETAIL
            WHERE  inventory_item_id = p_inventory_item_id
            AND    organization_id = p_organization_id
            AND    NVL ( containerized_flag, 2 ) = 2
            AND    subinventory_code = p_subinventory
            AND    NVL ( locator_id, -99 ) = NVL ( p_locator_id, -99 )
            AND    (    NVL ( lot_number, 'XX' ) = NVL ( p_lot_number, 'XX' )
                     OR p_lot_number IS NULL
                   ) -- Lot number might not have been entered yet
            AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

            SELECT NVL ( SUM ( quantity ), 0 )
            INTO   l_loaded_sys_qty
            FROM   WMS_LOADED_QUANTITIES_V
            WHERE  inventory_item_id = p_inventory_item_id
            AND    organization_id = p_organization_id
            AND    NVL ( containerized_flag, 2 ) = 2
            AND    subinventory_code = p_subinventory
            AND    NVL ( locator_id, -99 ) = NVL ( p_locator_id, -99 )
            AND    (    NVL ( lot_number, 'XX' ) = NVL ( p_lot_number, 'XX' )
                     OR p_lot_number IS NULL
                   )
            -- Lot number might not have been entered yet
            AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
            AND    qty_type = 'LOADED'
            AND    lpn_id IS NULL
            AND    content_lpn_id IS NULL; -- bug 2640378

            IF ( l_debug = 1 ) THEN
               print_debug ( 'Loaded qty is ' || l_loaded_sys_qty );
            END IF;

            IF l_loaded_sys_qty > 0 THEN
               x_system_quantity := x_system_quantity - l_loaded_sys_qty;
            END IF; -- bug 2640378
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is not null: ' || p_parent_lpn_id );
            END IF;

            BEGIN
               --For R12 we need to consider primary_quantity instead of quantity from WLC (bug 6833992)
               SELECT nvl(sum(primary_quantity),0)   --BUG3026540
               INTO   x_system_quantity
               FROM   WMS_LPN_CONTENTS
               WHERE  parent_lpn_id = p_parent_lpn_id
               AND    organization_id = p_organization_id
               AND    inventory_item_id = p_inventory_item_id
               AND    (    NVL ( lot_number, 'XX' ) =
                                                    NVL ( p_lot_number, 'XX' )
                        OR p_lot_number IS NULL
                      )
               -- Lot number might not have been entered yet
               AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
               AND    NVL ( serial_summary_entry, 2 ) = 2;

               SELECT NVL ( SUM ( quantity ), 0 )
               INTO   l_loaded_sys_qty
               FROM   wms_loaded_quantities_v
               WHERE  NVL ( lpn_id, NVL ( content_lpn_id, -1 ) ) = p_parent_lpn_id
               and    inventory_item_id = p_inventory_item_id
               and    organization_id = p_organization_id;

               IF l_loaded_sys_qty > 0 THEN
                  x_system_quantity := x_system_quantity - l_loaded_sys_qty;
               END IF;
            -- bug 2640378 does the counter need to know the missing quantity ?

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_system_quantity := 0;
            END;
         END IF;
      ELSIF ( l_serial_number_control_code IN ( 2, 5 ) ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Serial controlled item' );
         END IF;

         IF ( p_parent_lpn_id IS NULL ) THEN
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is null' );
            END IF;

            SELECT NVL ( SUM ( DECODE ( current_status, 3, 1, 0 ) ), 0 )
            INTO   x_system_quantity
            FROM   mtl_serial_numbers
            WHERE  lpn_id IS NULL
            AND    inventory_item_id = p_inventory_item_id
            AND    current_organization_id = p_organization_id
            AND    current_subinventory_code = p_subinventory
            AND    NVL ( current_locator_id, -99 ) = NVL ( p_locator_id, -99 )
            AND    (    NVL ( lot_number, 'XX' ) = NVL ( p_lot_number, 'XX' )
                     OR p_lot_number IS NULL
                   )
            -- Lot number might not have been entered yet
            AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

            select count(*)
            into   l_loaded_sys_qty
                           from   mtl_serial_numbers_temp msnt, wms_loaded_quantities_v wl
                           where  ((msnt.transaction_temp_id = wl.transaction_temp_id
                     and wl.lot_number is null) or
                                   (msnt.transaction_temp_id = wl.serial_transaction_temp_id
                     and wl.lot_number is not null)
                                       )
            and    wl.containerized_flag = 2
                           and    wl.inventory_item_id = p_inventory_item_id
                           and    wl.subinventory_code = p_subinventory
                           and    nvl(wl.locator_id,-99) = nvl(p_locator_id,-99)
            and    (nvl(wl.lot_number,'@@@') = nvl(p_lot_number,'@@@')
                    or p_lot_number is null)
            and    nvl(wl.revision,'##') = nvl(p_revision,'##');

            IF l_loaded_sys_qty > 0 THEN
                  x_system_quantity := x_system_quantity - l_loaded_sys_qty;
            END IF;
         ELSE
            IF ( l_debug = 1 ) THEN
               print_debug ( 'LPN ID is not null: ' || p_parent_lpn_id );
            END IF;

            SELECT COUNT ( * )
            INTO   x_system_quantity
            FROM   mtl_serial_numbers
            WHERE  lpn_id = p_parent_lpn_id
            AND    inventory_item_id = p_inventory_item_id
            AND    current_organization_id = p_organization_id
            AND    (    NVL ( lot_number, 'XX' ) = NVL ( p_lot_number, 'XX' )
                     OR p_lot_number IS NULL
                   )
            -- Lot number might not have been entered yet
            AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

            SELECT SUM(NVL( wl.quantity,0))  --9452528
            into   l_loaded_sys_qty
                      from   mtl_serial_numbers msn, wms_loaded_quantities_v wl
                           where  msn.lpn_id = nvl(wl.content_lpn_id,nvl(wl.lpn_id,-1))
                           and   wl.containerized_flag = 1
                      and    msn.inventory_item_id = wl.inventory_item_id
                      and    msn.current_organization_id = wl.ORGANIZATION_ID
                      and    wl.inventory_item_id = p_inventory_item_id
                           and    wl.organization_id = p_organization_id
                           and    msn.lpn_id = p_parent_lpn_id
            and    (nvl(msn.lot_number,'@@@') = nvl(wl.lot_number,'@@@') or
                   p_lot_number is null)
            AND    NVL ( wl.revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

            IF l_loaded_sys_qty > 0 THEN
                  x_system_quantity := x_system_quantity - l_loaded_sys_qty;
            END IF;
         END IF;
      END IF;

      l_progress  := '30';
      l_converted_quantity :=
         inv_convert.inv_um_convert ( p_inventory_item_id,
                                      5,
                                      x_system_quantity,
                                      l_primary_uom,
                                      p_uom_code,
                                      NULL,
                                      NULL
                                    );
      l_progress  := '40';
      x_system_quantity := l_converted_quantity;
   EXCEPTION
      WHEN OTHERS THEN
         IF ( l_debug = 1 ) THEN
            print_debug (    'Exiting get_system_quantity - other exceptions:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;
   END get_system_quantity;

   PROCEDURE clean_up_tasks (
      p_transaction_temp_id IN NUMBER
   )
   IS
      l_employee_id NUMBER;
      l_progress VARCHAR2 ( 10 );
      l_task_temp_id NUMBER;

      CURSOR completed_tasks_cursor
      IS
         SELECT wdt.transaction_temp_id
         FROM   wms_dispatched_tasks wdt
         WHERE  wdt.person_id = l_employee_id
         AND    wdt.task_type = 3
         AND    NOT EXISTS (
                   SELECT 'ACTIVE_TASK'
                   FROM   wms_dispatchable_tasks_v
                   WHERE  wms_task_type_id = 3
                   AND    task_id = wdt.transaction_temp_id );

      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         print_debug ( '***Calling clean_up_tasks***' );
      END IF;

      -- Set the savepoint first
      SAVEPOINT clean_up_tasks_sp;
      l_progress  := '10';

      -- Get the employee ID first for the person that performed the task
      SELECT DISTINCT NVL ( person_id, -999 )
      INTO            l_employee_id
      FROM            wms_dispatched_tasks_history
      WHERE           transaction_id = p_transaction_temp_id AND task_type = 3;

      IF ( l_debug = 1 ) THEN
         print_debug ( 'The employee ID is: ' || l_employee_id );
      END IF;

      IF ( l_employee_id = -999 ) THEN
         IF ( l_debug = 1 ) THEN
            print_debug ( 'The person ID for the completed task is null' );
         END IF;

         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_progress  := '20';

      FOR v_completed_task IN completed_tasks_cursor
      LOOP
         l_task_temp_id := v_completed_task.transaction_temp_id;

         IF ( l_debug = 1 ) THEN
            print_debug ( 'Cleaning up task with temp id: ' || l_task_temp_id );
         END IF;

         l_progress  := '30';

         -- Insert a record into the tasks history table
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Inserting record into tasks history table' );
         END IF;

         INSERT INTO WMS_DISPATCHED_TASKS_HISTORY
                     ( task_id,
                       transaction_id,
                       organization_id,
                       user_task_type,
                       person_id,
                       effective_start_date,
                       effective_end_date,
                       equipment_id,
                       equipment_instance,
                       person_resource_id,
                       machine_resource_id,
                       status,
                       dispatched_time,
                       loaded_time,
                       drop_off_time,
                       last_update_date,
                       last_updated_by,
                       creation_date,
                       created_by,
                       last_update_login,
                       attribute_category,
                       attribute1,
                       attribute2,
                       attribute3,
                       attribute4,
                       attribute5,
                       attribute6,
                       attribute7,
                       attribute8,
                       attribute9,
                       attribute10,
                       attribute11,
                       attribute12,
                       attribute13,
                       attribute14,
                       attribute15,
                       task_type,
                       priority,
                       task_group_id
                     )
            SELECT task_id,
                   transaction_temp_id,
                   organization_id,
                   user_task_type,
                   person_id,
                   effective_start_date,
                   effective_end_date,
                   equipment_id,
                   equipment_instance,
                   person_resource_id,
                   machine_resource_id,
                   6,
                   dispatched_time,
                   loaded_time,
                   drop_off_time,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   task_type,
                   priority,
                   task_group_id
            FROM   WMS_DISPATCHED_TASKS
            WHERE  TRANSACTION_TEMP_ID = l_task_temp_id AND TASK_TYPE = 3;

         l_progress  := '40';

         -- Now delete the completed task from the dispatched tasks table
         IF ( l_debug = 1 ) THEN
            print_debug ( 'Deleting the record from the dispatched tasks table'
                        );
         END IF;

         DELETE FROM WMS_DISPATCHED_TASKS
         WHERE       TRANSACTION_TEMP_ID = l_task_temp_id AND TASK_TYPE = 3;
      END LOOP;

      l_progress  := '50';

      IF ( l_debug = 1 ) THEN
         print_debug ( '***End of clean_up_tasks***' );
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO clean_up_tasks_sp;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exiting clean_up_tasks - execution error:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO clean_up_tasks_sp;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exiting clean_up_tasks - unexpected error:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;
      WHEN OTHERS THEN
         ROLLBACK TO clean_up_tasks_sp;

         IF ( l_debug = 1 ) THEN
            print_debug (    'Exitting clean_up_tasks - other exceptions:'
                          || l_progress
                          || ' '
                          || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                        );
         END IF;
   END clean_up_tasks;

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
		 p_revision							IN		VARCHAR2)

    IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_temp_exists VARCHAR2(1) := 'N';
    l_cc_id NUMBER;
	  l_parent_lpn_id NUMBER;
    l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN

    x_result_out := 'S';

		IF p_parent_lpn_id <= 0 THEN
			l_parent_lpn_id := NULL;
		ELSE
			l_parent_lpn_id := p_parent_lpn_id;
		END IF;

    IF ( l_debug = 1 ) THEN
            print_debug ( '***Inside update_cc_status***' );
            print_debug ( '***Inside update_cc_status p_organization_id : ***'||p_organization_id );
            print_debug ( '***Inside update_cc_status p_parent_lpn_id : ***'||p_parent_lpn_id );
						print_debug ( '***Inside update_cc_status l_parent_lpn_id : ***'||l_parent_lpn_id );
            print_debug ( '***Inside update_cc_status p_inventory_item_id : ***'||p_inventory_item_id );
            print_debug ( '***Inside update_cc_status p_sub_code : ***'||p_sub_code );
            print_debug ( '***Inside update_cc_status p_loc_id : ***'||p_loc_id );
            print_debug ( '***Inside update_cc_status p_cc_header_id : ***'||p_cc_header_id );
            print_debug ( '***Inside update_cc_status p_task_id : ***'||p_task_id );
            print_debug ( '***Inside update_cc_status p_revision : ***'||p_revision);
    END IF;


    SELECT Min(CYCLE_COUNT_ENTRY_ID)
      INTO l_cc_id
      FROM mtl_cycle_count_entries
     WHERE organization_id        = p_organization_id
       AND cycle_count_header_id  = p_cc_header_id
       AND entry_status_code     IN (1,3)
       AND inventory_item_id      = p_inventory_item_id
       AND Nvl(subinventory,'@@@')= Nvl(p_sub_code,'@@@')
       AND Nvl(locator_id,-999)   = Nvl(p_loc_id,-999)
       AND NVL ( parent_lpn_id, -99999 ) = NVL ( l_parent_lpn_id, -99999 )
       AND Nvl(revision,'###')    = Nvl(p_revision,'###');

    IF ( l_debug = 1 ) THEN
     print_debug ( 'l_cc_task_id : '||l_cc_id);
    END IF;

    BEGIN
    SELECT 'Y'
      INTO l_temp_exists
      FROM wms_dispatched_tasks
     WHERE transaction_temp_id =  l_cc_id
       AND status = 9;
    EXCEPTION
		WHEN NO_DATA_FOUND THEN
     l_temp_exists := 'N';
		 IF ( l_debug = 1 ) THEN
      print_debug ( '***Inside update_cc_status Exception Block- No data found while chking the wdt for temp_id***' );
     END IF;
    WHEN OTHERS THEN
     l_temp_exists := 'N';
     IF ( l_debug = 1 ) THEN
      print_debug ( '***Inside update_cc_status Exception Block- Others while chking the wdt for temp_id***' );
      print_debug ('Error Msg : '||SQLERRM||' Error Code: '||SQLCODE);
     END IF;
    END;

    IF (l_temp_exists = 'N') THEN
     IF ( l_debug = 1 ) THEN
       print_debug ( 'Updating wdt with temp_id : '||p_task_id||' to '||l_cc_id );
     END IF;

    UPDATE wms_dispatched_tasks
        SET transaction_temp_id = l_cc_id
      WHERE transaction_temp_id = p_task_id;

		IF ( l_debug = 1 ) THEN
     print_debug ( 'Upadated rows in wdt : '||SQL%rowcount );
		END IF;
    x_cc_id := l_cc_id;

    ELSE
     IF ( l_debug = 1 ) THEN
      print_debug ( 'No Need to Update rows in wdt ');
     END IF;

    x_cc_id := p_task_id;

    END IF;

  COMMIT;

  EXCEPTION
  WHEN No_Data_Found THEN
  x_result_out := 'E';
  x_cc_id := p_task_id;
  IF ( l_debug = 1 ) THEN
     print_debug ( '***Inside update_cc_status Exception Block- No Data Found***' );
  END IF;
  ROLLBACK;

  WHEN OTHERS THEN
  x_result_out := 'E';
  x_cc_id := p_task_id;
  IF ( l_debug = 1 ) THEN
     print_debug ( '***Inside update_cc_status Exception Block- Others***' );
     print_debug ('SQLERRM : '||SQLERRM||' SQLCODE: '||SQLCODE);
  END IF;
  ROLLBACK;

END update_cc_status;
--BUG# 9734316

END INV_CYC_LOVS;

/
