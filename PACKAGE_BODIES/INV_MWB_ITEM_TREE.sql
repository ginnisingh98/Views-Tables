--------------------------------------------------------
--  DDL for Package Body INV_MWB_ITEM_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_ITEM_TREE" AS
/* $Header: INVMWITB.pls 120.12 2008/01/10 23:00:54 musinha ship $ */

   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_ITEM_TREE';

   --
   -- private functions
   --
   -- PROCEDURE make_common_queries(p_flag VARCHAR2); -- Bug 6060233

   PROCEDURE root_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ROOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_items(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF inv_mwb_globals.g_serial_from IS NOT NULL OR
            inv_mwb_globals.g_serial_to IS NOT NULL
            OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
         inv_mwb_query_manager.execute_query;

      END IF; -- tree event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END root_node_event;

   PROCEDURE item_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
     l_procedure_name VARCHAR2(30);

   BEGIN

     l_procedure_name := 'ITEM_NODE_EVENT';

     IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
        inv_mwb_tree1.add_orgs(
                      x_node_value
                    , x_node_tbl
                    , x_tbl_index
                    );
     ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

        IF inv_mwb_globals.g_chk_onhand = 1 THEN
           IF inv_mwb_globals.g_serial_from IS NOT NULL OR
              inv_mwb_globals.g_serial_to IS NOT NULL
              OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
	      OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
              make_common_queries('MSN_QUERY');
              inv_mwb_query_manager.add_where_clause(
                                   'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                                   'ONHAND'
                                   );
              inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
           ELSE
              make_common_queries('MOQD');
              inv_mwb_query_manager.add_where_clause(
                                   'moqd.inventory_item_id = :onh_tree_inventory_item_id' ,
                                   'ONHAND'
                                   );

              inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
           END IF; -- serial
           inv_mwb_query_manager.add_bind_variable(
                                'onh_tree_inventory_item_id',
                                inv_mwb_globals.g_tree_item_id
                                );
           inv_mwb_query_manager.execute_query;
        END IF;  -- onhand

     END IF; -- node seleted
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END item_node_event;

   PROCEDURE org_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);
      l_rev_control    NUMBER;
      l_lot_control    NUMBER;
      l_serial_control NUMBER;

   BEGIN

      l_procedure_name := 'ORG_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_revs(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

         IF x_tbl_index = 1 THEN
            inv_mwb_tree1.add_lots(
                          x_node_value
                        , x_node_tbl
                        , x_tbl_index
                        );

            IF x_tbl_index = 1 THEN
               inv_mwb_tree1.add_serials(
                             x_node_value
                           , x_node_tbl
                           , x_tbl_index
                           );
            END IF;
         END IF;

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT revision_qty_control_code,
                lot_control_code,
                serial_number_control_code
         INTO   l_rev_control,
                l_lot_control,
                l_serial_control
         FROM   mtl_system_items
         WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
         AND    organization_id = inv_mwb_globals.g_tree_organization_id;

         IF inv_mwb_globals.g_chk_onhand = 1 THEN

            IF NVL(l_rev_control, 1) = 1 AND NVL(l_lot_control, 1) = 1
               AND l_serial_control IN ( 2,5 ) THEN

               make_common_queries('MSN');
               inv_mwb_query_manager.add_where_clause(
                                    'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                                    'ONHAND'
                                    );
               inv_mwb_query_manager.add_where_clause(
                                    'msn.current_organization_id = :onh_tree_organization_id' ,
                                    'ONHAND'
                                    );
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE  -- only serial controlled
               IF inv_mwb_globals.g_serial_from IS NOT NULL OR
                  inv_mwb_globals.g_serial_to IS NOT NULL
                  OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
		  OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
                  make_common_queries('MSN_QUERY');
                  IF l_rev_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'msn.revision';
                     inv_mwb_query_manager.add_group_clause('msn.revision', 'ONHAND');
                  END IF;
                  IF NVL(l_rev_control, 1) = 1  AND l_lot_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'msn.lot_number';
                     inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');
                  END IF;
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.current_organization_id = :onh_tree_organization_id' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
               ELSE -- serial entered in qf
                  make_common_queries('MOQD');
                  inv_mwb_query_manager.add_where_clause(
                                       'moqd.inventory_item_id = :onh_tree_inventory_item_id' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_where_clause(
                                       'moqd.organization_id = :onh_tree_organization_id' ,
                                       'ONHAND'
                                       );
                  IF l_rev_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'moqd.revision';
                     inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
                  END IF;
                  IF NVL(l_rev_control, 1) = 1  AND l_lot_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'moqd.lot_number';
                     inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
                  END IF;

                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               END IF; -- serial in query find
            END IF;  -- only serial controlled
            inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_organization_id',
                                 inv_mwb_globals.g_tree_organization_id
                                 );
            inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_inventory_item_id',
                                 inv_mwb_globals.g_tree_item_id
                                 );
         END IF; -- onhand check
         inv_mwb_query_manager.execute_query;

      END IF; -- tree event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END org_node_event;


   PROCEDURE rev_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);
      l_lot_control    NUMBER;
      l_serial_control NUMBER;

   BEGIN

      l_procedure_name := 'REV_NODE_EVENT';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_lots(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

         IF x_tbl_index = 1 THEN
            inv_mwb_tree1.add_serials(
                          x_node_value
                        , x_node_tbl
                        , x_tbl_index
                        );
         END IF;

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT lot_control_code,
                serial_number_control_code
         INTO   l_lot_control,
                l_serial_control
         FROM   mtl_system_items
         WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
         AND    organization_id = inv_mwb_globals.g_tree_organization_id;

         IF inv_mwb_globals.g_chk_onhand = 1 THEN

            IF l_lot_control = 1 AND l_serial_control IN ( 2,5 ) THEN
               make_common_queries('MSN');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                   'msn.revision';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                   'msn.serial_number';
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.organization_id = :onh_tree_organization_id' ,'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.revision = :onh_tree_revision' ,'ONHAND');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE -- l_serial_control
               IF inv_mwb_globals.g_serial_from IS NOT NULL OR
                  inv_mwb_globals.g_serial_to IS NOT NULL
                  OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
		  OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
                  make_common_queries('MSN_QUERY');
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'msn.revision';
                  inv_mwb_query_manager.add_group_clause('msn.revision', 'ONHAND'); -- Bug 6060233
                  IF l_lot_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'msn.lot_number';
                     inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');
                  END IF;
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.current_organization_id = :onh_tree_organization_id' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.revision = :onh_tree_revision' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
               ELSE -- serial entered in qf
                  make_common_queries('MOQD');
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'moqd.revision';
                  inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
                  inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
                  inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                  inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');
                  IF l_lot_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'moqd.lot_number';
                     inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
                  END IF;

                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               END IF; -- serial entered in qf
            END IF;  -- l_serial_control
            inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_organization_id',
                                 inv_mwb_globals.g_tree_organization_id
                                 );
            inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_inventory_item_id',
                                 inv_mwb_globals.g_tree_item_id
                                 );
            inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_revision',
                                 inv_mwb_globals.g_tree_rev
                                 );
        END IF;  --chk_onhand
        inv_mwb_query_manager.execute_query;
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END rev_node_event;

   PROCEDURE lot_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);
      l_rev_control    NUMBER;
      l_serial_control NUMBER;

   BEGIN

      l_procedure_name := 'LOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_serials(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT revision_qty_control_code,
                serial_number_control_code
         INTO   l_rev_control,
                l_serial_control
         FROM   mtl_system_items
         WHERE  organization_id = inv_mwb_globals.g_tree_organization_id
         AND    inventory_item_id = inv_mwb_globals.g_tree_item_id;

         IF inv_mwb_globals.g_chk_onhand = 1 THEN

            IF l_serial_control IN ( 2,5 ) THEN
               make_common_queries('MSN');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                 'msn.lot_number';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                                 'msn.serial_number';
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id' ,'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.lot_number = :onh_tree_lot_number' ,'ONHAND');
               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                 'msn.revision';
                  inv_mwb_query_manager.add_where_clause('msn.revision = :onh_tree_revision' ,'ONHAND');
               END IF;
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE -- l_serial_control
               IF inv_mwb_globals.g_serial_from IS NOT NULL OR
                  inv_mwb_globals.g_serial_to IS NOT NULL
                  OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
		  OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
                  make_common_queries('MSN_QUERY');
                  IF l_rev_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'msn.revision';
                     inv_mwb_query_manager.add_where_clause('msn.revision = :onh_tree_revision' ,'ONHAND');
                     inv_mwb_query_manager.add_group_clause('msn.revision', 'ONHAND');
                  END IF;
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'msn.lot_number';
                  inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.current_organization_id = :onh_tree_organization_id' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_where_clause(
                                       'msn.lot_number = :onh_tree_lot_number' ,
                                       'ONHAND'
                                       );
                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
               ELSE -- serial entered in qf
                  make_common_queries('MOQD');
                  IF l_rev_control = 2 THEN
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                          'moqd.revision';
                     inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');
                     inv_mwb_query_manager.add_group_clause('moqd.revision','ONHAND');
                  END IF;
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'moqd.lot_number';
                  inv_mwb_query_manager.add_group_clause('moqd.lot_number','ONHAND');

                  inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
                  inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                  inv_mwb_query_manager.add_where_clause('moqd.lot_number = :onh_tree_lot_number' ,'ONHAND');

                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               END IF; -- serial entered in qf
            END IF; -- l_serial_control
            inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_lot_number', inv_mwb_globals.g_tree_lot_number);
            IF l_rev_control = 2 THEN
               inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);
            END IF;
        END IF;  --chk_onhand
        inv_mwb_query_manager.execute_query;

      END IF; -- tree event
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END lot_node_event;

   PROCEDURE serial_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);
      l_rev_control    NUMBER;
      l_lot_control    NUMBER;
   BEGIN

      l_procedure_name := 'SERIAL_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT revision_qty_control_code,
                lot_control_code
         INTO   l_rev_control,
                l_lot_control
         FROM   mtl_system_items
         WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
         AND    organization_id = inv_mwb_globals.g_tree_organization_id;

         IF inv_mwb_globals.g_chk_onhand = 1 THEN
            make_common_queries('MSN');
            inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id' ,'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
            IF l_rev_control = 2 THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                 'msn.revision';
               inv_mwb_query_manager.add_where_clause('msn.revision = :onh_tree_revision' ,'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);
            END IF;
            IF l_lot_control = 2 THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                 'msn.lot_number';
               inv_mwb_query_manager.add_where_clause('msn.lot_number = :onh_lot_number' ,'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lot_number', inv_mwb_globals.g_tree_lot_number);
            END IF;
            inv_mwb_query_manager.add_where_clause('msn.serial_number = :onh_serial_number' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.current_status = 3' ,'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_serial_number', inv_mwb_globals.g_tree_serial_number);

        END IF;
        inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
        inv_mwb_query_manager.execute_query;
      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END serial_node_event;

   PROCEDURE make_common_queries(p_flag VARCHAR2) IS
   BEGIN

      IF(inv_mwb_globals.g_chk_onhand = 1) THEN

         CASE p_flag
            WHEN 'MSN' THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                  'msn.inventory_item_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
                  'msn.current_organization_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                  '''Ea''';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value := 1;

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                  'DECODE(msn.lpn_id, NULL, 0,1)';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                  'DECODE(msn.lpn_id, NULL, 1,0)';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
                  'NULL';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_PACKED).column_value :=
                  'NULL';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UNPACKED).column_value :=
                  'NULL';

                inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                   'msn.serial_number';

               inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');

            WHEN 'MOQD' THEN

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                  'moqd.inventory_item_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
                  'moqd.organization_id';

--               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
--                  'moqd.transaction_uom_code';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
                  'SUM(moqd.primary_transaction_quantity)';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                  'SUM(DECODE(moqd.containerized_flag, 1, moqd.primary_transaction_quantity, 0))';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                  'SUM(DECODE(moqd.containerized_flag, 1, 0, moqd.primary_transaction_quantity))';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
                  'moqd.secondary_uom_code';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_ONHAND).column_value :=
                  'SUM(moqd.secondary_transaction_quantity)';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_PACKED).column_value :=
                  'SUM(DECODE(moqd.containerized_flag, 1, moqd.secondary_transaction_quantity, 0))';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UNPACKED).column_value :=
                  'SUM(DECODE(moqd.containerized_flag, 1, 0, moqd.secondary_transaction_quantity))';

               inv_mwb_query_manager.add_from_clause('mtl_onhand_quantities_detail moqd', 'ONHAND');

               inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.organization_id', 'ONHAND');
--               inv_mwb_query_manager.add_group_clause('moqd.transaction_uom_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.secondary_uom_code', 'ONHAND');

            WHEN 'MSN_QUERY' THEN
               -- Bug 6060233
	       inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                  'msn.inventory_item_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
                  'msn.current_organization_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                  '''Ea''';
		-- End Bug 6060233
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
                                       'count(1)';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                                       'count(decode(msn.lpn_id,NULL,0, 1))';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                                       'count(decode(msn.lpn_id,NULL,1, 0))';
               inv_mwb_query_manager.add_group_clause('msn.inventory_item_id' , 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('''Ea''', 'ONHAND');

               inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');
         END CASE; -- p_flag

      END IF; -- End if for onhand

   END make_common_queries;


--
-- public functions
--

--
-- General APPTREE event handler
--
   PROCEDURE event (
    x_node_value IN OUT NOCOPY NUMBER
  , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index  IN OUT NOCOPY NUMBER
  ) IS

      l_procedure_name VARCHAR2(30);
   BEGIN

      l_procedure_name := 'EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' OR
         inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         CASE inv_mwb_globals.g_tree_node_type
            WHEN 'APPTREE_OBJECT_TRUNK' THEN
               root_node_event (
                         x_node_value
                       , x_node_tbl
                       , x_tbl_index
                       );
            WHEN 'ORG' THEN
               org_node_event (
                        x_node_value
                      , x_node_tbl
                      , x_tbl_index
                      );
            WHEN 'ITEM' THEN
               item_node_event (
                         x_node_value
                       , x_node_tbl
                       , x_tbl_index
                       );
            WHEN 'REV' THEN
               rev_node_event (
                        x_node_value
                      , x_node_tbl
                      , x_tbl_index
                      );
            WHEN 'LOT' THEN
               lot_node_event (
                        x_node_value
                      , x_node_tbl
                      , x_tbl_index
                      );
            WHEN 'SERIAL' THEN
               serial_node_event (
                           x_node_value
                         , x_node_tbl
                         , x_tbl_index
                         );
         END CASE;

      END IF; -- g_tree_event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END event;

END INV_MWB_ITEM_TREE;

/
