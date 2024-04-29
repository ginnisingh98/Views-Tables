--------------------------------------------------------
--  DDL for Package Body INV_MWB_GRADE_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_GRADE_TREE" AS
/* $Header: INVMWGRB.pls 120.6.12000000.2 2007/10/17 08:20:36 athammin ship $ */
-- NSRIVAST, INVCONV, Start

   g_pkg_name CONSTANT VARCHAR2(30) := 'GRADE_TREE_EVENT';

   PROCEDURE make_common_queries(p_flag VARCHAR2);

   PROCEDURE root_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ROOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_grades(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF inv_mwb_globals.g_serial_from IS NOT NULL  OR
            inv_mwb_globals.g_serial_to IS NOT NULL
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
         inv_mwb_query_manager.execute_query;
      END IF; -- g_tree_event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END root_node_event;


   PROCEDURE grade_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'GRADE_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_orgs(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF inv_mwb_globals.g_serial_from IS NOT NULL  OR
            inv_mwb_globals.g_serial_to IS NOT NULL
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
         inv_mwb_query_manager.add_where_clause('mln.grade_code = :onh_tree_grade_code ', 'ONHAND');
         inv_mwb_query_manager.add_bind_variable('onh_tree_grade_code', inv_mwb_globals.g_tree_grade_code);
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END grade_node_event;


   PROCEDURE org_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ORG_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_items(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF inv_mwb_globals.g_serial_from IS NOT NULL  OR
            inv_mwb_globals.g_serial_to IS NOT NULL
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_queries('MSN_QUERY');

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                    'msn.inventory_item_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                    '''Ea''';

            inv_mwb_query_manager.add_group_clause(
                                  'msn.inventory_item_id',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_group_clause(
                                  '''Ea''',
                                  'ONHAND'
                                  );

            inv_mwb_query_manager.add_where_clause(
                                  'msn.current_organization_id = :onh_tree_organization_id ',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                    'moqd.inventory_item_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                    'moqd.transaction_uom_code';

            inv_mwb_query_manager.add_group_clause(
                                  'moqd.inventory_item_id',
                                  'ONHAND'
                                  );

            inv_mwb_query_manager.add_group_clause(
                                 'moqd.transaction_uom_code',
                                 'ONHAND'
                                 );

            inv_mwb_query_manager.add_where_clause(
                                  'moqd.organization_id = :onh_tree_organization_id ',
                                  'ONHAND'
                                  );

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

            make_common_queries('MOQD');
         END IF;

         inv_mwb_query_manager.add_where_clause(
                               'mln.grade_code = :onh_tree_grade_code ',
                               'ONHAND'
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_organization_id',
                               inv_mwb_globals.g_tree_organization_id
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_grade_code',
                               inv_mwb_globals.g_tree_grade_code
                               );

         inv_mwb_query_manager.execute_query;

      END IF; -- g_tree_event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END org_node_event;


   PROCEDURE item_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ITEM_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_lots(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF inv_mwb_globals.g_serial_from IS NOT NULL  OR
            inv_mwb_globals.g_serial_to IS NOT NULL
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_queries('MSN_QUERY');

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                    'msn.lot_number';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                    'msn.inventory_item_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                    '''Ea''';

            inv_mwb_query_manager.add_group_clause(
                                  'msn.inventory_item_id',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_group_clause(
                                  '''Ea''',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_group_clause(
                                  'msn.lot_number',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_where_clause(
                                  'msn.current_organization_id = :onh_tree_organization_id ',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_where_clause(
                                  'msn.inventory_item_id = :onh_tree_inventory_item_id ',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                    'moqd.lot_number';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                    'moqd.inventory_item_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                    'moqd.transaction_uom_code';

            inv_mwb_query_manager.add_group_clause(
                                  'moqd.inventory_item_id',
                                  'ONHAND'
                                  );

            inv_mwb_query_manager.add_where_clause(
                                  'moqd.organization_id = :onh_tree_organization_id ',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_where_clause(
                                  'moqd.inventory_item_id = :onh_tree_inventory_item_id ',
                                  'ONHAND'
                                  );
            inv_mwb_query_manager.add_group_clause(
                                 'moqd.transaction_uom_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause(
                                  'moqd.lot_number',
                                  'ONHAND'
                                  );

            make_common_queries('MOQD');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
         inv_mwb_query_manager.add_where_clause(
                               'mln.grade_code = :onh_tree_grade_code ',
                               'ONHAND'
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_organization_id',
                               inv_mwb_globals.g_tree_organization_id
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_inventory_item_id',
                               inv_mwb_globals.g_tree_item_id
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_grade_code',
                               inv_mwb_globals.g_tree_grade_code
                               );

         inv_mwb_query_manager.execute_query;

      END IF; -- g_tree_event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END item_node_event;

   PROCEDURE lot_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);
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

         SELECT serial_number_control_code
           INTO l_serial_control
           FROM mtl_system_items
          WHERE inventory_item_id = inv_mwb_globals.g_tree_item_id
            AND organization_id = inv_mwb_globals.g_tree_organization_id;

         IF l_serial_control IN (2,5) THEN
            make_common_queries('MSN');
            inv_mwb_query_manager.add_where_clause(
                                 'msn.current_organization_id = :onh_tree_organization_id ',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'msn.inventory_item_id = :onh_tree_inventory_item_id ',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'msn.lot_number = :onh_tree_lot_number ',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE -- not serial controlled
            IF inv_mwb_globals.g_serial_from IS NOT NULL  OR
               inv_mwb_globals.g_serial_to IS NOT NULL
	       OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_queries('MSN_QUERY');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                       'msn.lot_number';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                       'msn.inventory_item_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                       '''Ea''';

               inv_mwb_query_manager.add_group_clause(
                                     'msn.inventory_item_id',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_group_clause(
                                     '''Ea''',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_group_clause(
                                     'msn.lot_number',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_where_clause(
                                     'msn.current_organization_id = :onh_tree_organization_id ',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_where_clause(
                                     'msn.inventory_item_id = :onh_tree_inventory_item_id ',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_where_clause(
                                    'msn.lot_number = :onh_tree_lot_number ',
                                    'ONHAND'
                                    );

               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE
               make_common_queries('MOQD');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                       'moqd.lot_number';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                       'moqd.inventory_item_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                       'moqd.transaction_uom_code';

               inv_mwb_query_manager.add_group_clause(
                                     'moqd.inventory_item_id',
                                     'ONHAND'
                                     );

               inv_mwb_query_manager.add_where_clause(
                                     'moqd.organization_id = :onh_tree_organization_id ',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_where_clause(
                                     'moqd.inventory_item_id = :onh_tree_inventory_item_id ',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_where_clause(
                                    'moqd.lot_number = :onh_tree_lot_number ',
                                    'ONHAND'
                                    );

               inv_mwb_query_manager.add_group_clause(
                                    'moqd.transaction_uom_code',
                                    'ONHAND'
                                    );
               inv_mwb_query_manager.add_group_clause(
                                    'moqd.secondary_uom_code',
                                    'ONHAND'
                                    );
               inv_mwb_query_manager.add_group_clause(
                                     'moqd.lot_number',
                                     'ONHAND'
                                     );
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
            END IF;

         END IF; -- not serial controlled
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.GRADE_CODE).column_value :=
                 'mln.grade_code';
         inv_mwb_query_manager.add_where_clause(
                               'mln.grade_code = :onh_tree_grade_code ',
                               'ONHAND'
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_organization_id',
                               inv_mwb_globals.g_tree_organization_id
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_inventory_item_id',
                               inv_mwb_globals.g_tree_item_id
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_grade_code',
                               inv_mwb_globals.g_tree_grade_code
                               );
         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_lot_number',
                               inv_mwb_globals.g_tree_lot_number
                               );

         inv_mwb_query_manager.execute_query;
      END IF; --g_tree_event

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

   BEGIN

      l_procedure_name := 'SERIAL_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.GRADE_CODE).column_value :=
                 'mln.grade_code';

         make_common_queries('MSN');
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id ',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.inventory_item_id = :onh_tree_inventory_item_id ',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.lot_number = :onh_tree_lot_number ',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                               'mln.grade_code = :onh_tree_grade_code ',
                               'ONHAND'
                               );
         inv_mwb_query_manager.add_where_clause(
                              'msn.serial_number = :onh_tree_serial_number ',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_organization_id',
                               inv_mwb_globals.g_tree_organization_id
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_inventory_item_id',
                               inv_mwb_globals.g_tree_item_id
                               );

         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_grade_code',
                               inv_mwb_globals.g_tree_grade_code
                               );
         inv_mwb_query_manager.add_bind_variable(
                               'onh_tree_lot_number',
                               inv_mwb_globals.g_tree_lot_number
                               );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_serial_number',
                              inv_mwb_globals.g_tree_serial_number
                              );

         inv_mwb_query_manager.execute_query;



      END IF; -- g_tree_event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END serial_node_event;

   PROCEDURE make_common_queries(p_flag VARCHAR2) IS
      l_rev_control    NUMBER;
      l_lot_control    NUMBER;
      l_serial_control NUMBER;
   BEGIN

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
               'SUM(DECODE(msn.lpn_id, NULL, 0,1))';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
               'SUM(DECODE(msn.lpn_id, NULL, 1,0))';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
               'msn.serial_number';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_organization_id).column_value :=
               'msn.owning_organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_organization_id).column_value :=
               'msn.planning_organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_tp_type).column_value :=
               'msn.owning_tp_type';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_tp_type).column_value :=
               'msn.planning_tp_type';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.GRADE_CODE).column_value :=
               'mln.grade_code';

            inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');
            inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');

            inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.lot_number = mln.lot_number', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('mln.grade_code IS NOT NULL', 'ONHAND');

            inv_mwb_query_manager.add_group_clause('msn.serial_number', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.planning_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.planning_tp_type', 'ONHAND');
	         inv_mwb_query_manager.add_group_clause('msn.owning_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.owning_tp_type', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('mln.grade_code', 'ONHAND');



         WHEN 'MOQD' THEN

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'moqd.organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
               'moqd.inventory_item_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_organization_id).column_value :=
               'moqd.owning_organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_organization_id).column_value :=
               'moqd.planning_organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_tp_type).column_value :=
               'moqd.owning_tp_type';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_tp_type).column_value :=
               'moqd.planning_tp_type';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.GRADE_CODE).column_value :=
               'mln.grade_code';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
               'moqd.secondary_uom_code';

   	      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
               'SUM(moqd.primary_transaction_quantity)';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
               'SUM(DECODE(moqd.containerized_flag, 1, moqd.primary_transaction_quantity, 0))';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
               'SUM(DECODE(moqd.containerized_flag, 1, 0, moqd.primary_transaction_quantity))';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_ONHAND).column_value :=
               'SUM(moqd.secondary_transaction_quantity)';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_PACKED).column_value :=
               'SUM(DECODE(moqd.containerized_flag, 1, moqd.secondary_transaction_quantity, 0))';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UNPACKED).column_value :=
               'SUM(DECODE(moqd.containerized_flag, 1, 0, moqd.secondary_transaction_quantity))';

            inv_mwb_query_manager.add_from_clause('mtl_onhand_quantities_detail moqd', 'ONHAND');
            inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.lot_number = mln.lot_number', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('mln.grade_code IS NOT NULL', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = mln.inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.organization_id = mln.organization_id', 'ONHAND');

            inv_mwb_query_manager.add_group_clause('moqd.organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.planning_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.planning_tp_type', 'ONHAND');
      	    inv_mwb_query_manager.add_group_clause('moqd.owning_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.owning_tp_type', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('mln.grade_code', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.secondary_uom_code', 'ONHAND');



         WHEN 'MSN_QUERY' THEN


            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
               'msn.inventory_item_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'msn.current_organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
               '''Ea''';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
               'count(1)';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
               'SUM(DECODE(msn.lpn_id, NULL, 0,1))';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
               'SUM(DECODE(msn.lpn_id, NULL, 1,0))';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_organization_id).column_value :=
               'msn.owning_organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_organization_id).column_value :=
               'msn.planning_organization_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_tp_type).column_value :=
               'msn.owning_tp_type';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_tp_type).column_value :=
               'msn.planning_tp_type';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.GRADE_CODE).column_value :=
               'mln.grade_code';

            inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');
            inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');

            inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.lot_number = mln.lot_number', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('mln.grade_code IS NOT NULL', 'ONHAND');

            inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.planning_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.planning_tp_type', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.owning_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.owning_tp_type', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('mln.grade_code', 'ONHAND');


      END CASE; -- p_flag

   END make_common_queries;

   PROCEDURE event  (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED'
      OR inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         CASE inv_mwb_globals.g_tree_node_type

            WHEN 'APPTREE_OBJECT_TRUNK' THEN
                root_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );
            WHEN 'GRADE' THEN
                grade_node_event (
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
      END IF; -- g_event_type
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END event;

END INV_MWB_GRADE_TREE;

/
