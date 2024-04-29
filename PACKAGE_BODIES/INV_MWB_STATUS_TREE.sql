--------------------------------------------------------
--  DDL for Package Body INV_MWB_STATUS_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_STATUS_TREE" AS
/* $Header: INVMWSTB.pls 120.11 2008/01/11 09:16:45 musinha ship $ */

   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_STATUS_TREE';

   --
   -- private functions
   --
   PROCEDURE make_common_queries(p_flag IN VARCHAR2);

   PROCEDURE root_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ROOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_statuses(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );
      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END root_node_event;

   PROCEDURE status_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'STATUS_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_orgs(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );
      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END status_node_event;

-- Onhand Material Status support
   PROCEDURE onhand_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

     l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ONHAND_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
         make_common_queries('MOQD');
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
         'moqd.inventory_item_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
         'moqd.revision';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
         'moqd.subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
         'moqd.locator_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
         'moqd.lot_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
         'moqd.lpn_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
         'moqd.status_id';

         inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');

         inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         inv_mwb_query_manager.add_where_clause(
                              'moqd.status_id = :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END onhand_node_event;

   PROCEDURE org_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);

      i NUMBER := 1;
      j number := 1;
      l_default_status_id    NUMBER; -- Onhand Material Status Support
   BEGIN

      l_procedure_name := 'ORG_NODE_EVENT';

      if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
          l_default_status_id :=  inv_cache.org_rec.default_status_id;
      end if;

      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'default org status id: '||l_default_status_id);

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         If l_default_status_id is not null then -- Onhand Material Status Support
             x_node_tbl(i).state := -1;
             x_node_tbl(i).depth := 1;
             x_node_tbl(i).label := 'Onhand';
             x_node_tbl(i).icon  := 'affldhdr';
             x_node_tbl(i).value := 'ONHAND_FOLDER';
             x_node_tbl(i).type  := 'ONHAND_FOLDER';
             i := i + 1;

             x_node_tbl(i).state := -1;
             x_node_tbl(i).depth := 1;
             x_node_tbl(i).label := 'Serials';
             x_node_tbl(i).icon  := 'affldhdr';
             x_node_tbl(i).value := 'SERIAL_FOLDER';
             x_node_tbl(i).type  := 'SERIAL_FOLDER';
         else
             x_node_tbl(i).state := -1;
             x_node_tbl(i).depth := 1;
             x_node_tbl(i).label := 'Subinventories';
             x_node_tbl(i).icon  := 'affldhdr';
             x_node_tbl(i).value := 'SUB_FOLDER';
             x_node_tbl(i).type  := 'SUB_FOLDER';
             i := i + 1;

             x_node_tbl(i).state := -1;
             x_node_tbl(i).depth := 1;
             x_node_tbl(i).label := 'Locators';
             x_node_tbl(i).icon  := 'affldhdr';
             x_node_tbl(i).value := 'LOC_FOLDER';
             x_node_tbl(i).type  := 'LOC_FOLDER';
             i := i + 1;

             x_node_tbl(i).state := -1;
             x_node_tbl(i).depth := 1;
             x_node_tbl(i).label := 'Lots';
             x_node_tbl(i).icon  := 'affldhdr';
             x_node_tbl(i).value := 'LOT_FOLDER';
             x_node_tbl(i).type  := 'LOT_FOLDER';
             i := i + 1;

             x_node_tbl(i).state := -1;
             x_node_tbl(i).depth := 1;
             x_node_tbl(i).label := 'Serials';
             x_node_tbl(i).icon  := 'affldhdr';
             x_node_tbl(i).value := 'SERIAL_FOLDER';
             x_node_tbl(i).type  := 'SERIAL_FOLDER';
         END IF;
       ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

          NULL;

       END IF;
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END org_node_event;

   PROCEDURE sub_folder_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'SUB_FOLDER_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_subs(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF ( inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL )
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                  'msn.current_subinventory_code';

            inv_mwb_query_manager.add_from_clause('mtl_secondary_inventories msi', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'msi.secondary_inventory_name = msn.current_subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'msi.organization_id = msn.current_organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                  'moqd.subinventory_code';
            inv_mwb_query_manager.add_from_clause('mtl_secondary_inventories msi', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'msi.secondary_inventory_name = moqd.subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'msi.organization_id = moqd.organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

         END IF;
         inv_mwb_query_manager.add_where_clause(
                              'msi.organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msi.status_id = :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.execute_query;

      END IF;
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END sub_folder_node_event;


   PROCEDURE loc_folder_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'LOC_FOLDER_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_locs(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF ( inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL )
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                  'msn.current_locator_id';

            inv_mwb_query_manager.add_from_clause('mtl_item_locations mil', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mil.inventory_location_id = msn.current_locator_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.subinventory_code = msn.current_subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.organization_id = msn.current_organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                  'moqd.locator_id';
            inv_mwb_query_manager.add_from_clause('mtl_item_locations mil', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mil.inventory_location_id = moqd.locator_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.subinventory_code = moqd.subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.organization_id = moqd.organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

         END IF;
         inv_mwb_query_manager.add_where_clause(
                              'mil.organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'mil.status_id = :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END loc_folder_node_event;

   PROCEDURE lot_folder_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'LOT_FOLDER_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_lots(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF ( inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL )
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                  'msn.lot_number';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                  'msn.inventory_item_id';
            inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mln.lot_number = msn.lot_number',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.organization_id = msn.current_organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.inventory_item_id = msn.inventory_item_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                  'moqd.lot_number';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                  'moqd.inventory_item_id';
            inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mln.lot_number = moqd.lot_number',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.organization_id = moqd.organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.inventory_item_id = moqd.inventory_item_id',
                                 'ONHAND'
                                 );

            inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

         END IF;
         inv_mwb_query_manager.add_where_clause(
                              'mln.organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'mln.status_id = :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END lot_folder_node_event;

   PROCEDURE serial_folder_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'SERIAL_FOLDER_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_serials(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         make_common_queries('MSN');
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.status_id =  :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         inv_mwb_query_manager.execute_query;

      END IF; --tree event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END serial_folder_node_event;

   PROCEDURE sub_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

     l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'SUB_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF ( inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL )
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                  'msn.current_subinventory_code';

            inv_mwb_query_manager.add_from_clause('mtl_secondary_inventories msi', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'msi.secondary_inventory_name = msn.current_subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'msi.organization_id = msn.current_organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                  'moqd.subinventory_code';
            inv_mwb_query_manager.add_from_clause('mtl_secondary_inventories msi', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'msi.secondary_inventory_name = moqd.subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'msi.organization_id = moqd.organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

         END IF;
         inv_mwb_query_manager.add_where_clause(
                              'msi.secondary_inventory_name = :onh_tree_subinventory_code',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msi.organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msi.status_id = :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_subinventory_code',
                              inv_mwb_globals.g_tree_subinventory_code
                              );
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END sub_node_event;

   PROCEDURE loc_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'LOC_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF ( inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL )
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                  'msn.current_locator_id';

            inv_mwb_query_manager.add_from_clause('mtl_item_locations mil', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mil.inventory_location_id = msn.current_locator_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.subinventory_code = msn.current_subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.organization_id = msn.current_organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                  'moqd.locator_id';
            inv_mwb_query_manager.add_from_clause('mtl_item_locations mil', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mil.inventory_location_id = moqd.locator_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.subinventory_code = moqd.subinventory_code',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mil.organization_id = moqd.organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

         END IF;
         inv_mwb_query_manager.add_where_clause(
                              'mil.inventory_location_id = :onh_tree_locator_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'mil.organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'mil.status_id = :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_locator_id',
                              inv_mwb_globals.g_tree_loc_id
                              );
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END loc_node_event;

   PROCEDURE lot_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'LOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF ( inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL )
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                  'msn.lot_number';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                  'msn.inventory_item_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                  'msn.current_subinventory_code';--VARAJAGO

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                  'msn.current_locator_id';--VARAJAGO

	    inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mln.lot_number = msn.lot_number',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.organization_id = msn.current_organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.inventory_item_id = msn.inventory_item_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');--VARAJAGO
            inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');--VARAJAGO

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                  'moqd.lot_number';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                  'moqd.inventory_item_id';

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                  'moqd.subinventory_code';--VARAJAGO

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                  'moqd.locator_id';--VARAJAGO


	    inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');
            inv_mwb_query_manager.add_where_clause(
                                 'mln.lot_number = moqd.lot_number',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.organization_id = moqd.organization_id',
                                 'ONHAND'
                                 );
            inv_mwb_query_manager.add_where_clause(
                                 'mln.inventory_item_id = moqd.inventory_item_id',
                                 'ONHAND'
                                 );

            inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');

	    inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');--VARAJAGO
            inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');--VARAJAGO

	    inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

         END IF;
         inv_mwb_query_manager.add_where_clause(
                              'mln.lot_number = :onh_tree_lot_number',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'mln.organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'mln.status_id = :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_lot_number',
                              inv_mwb_globals.g_tree_lot_number
                              );
         inv_mwb_query_manager.execute_query;

      END IF;

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

         make_common_queries('MSN');
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.status_id =  :onh_tree_status_id',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.serial_number =  :onh_tree_serial_number',
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_status_id',
                              inv_mwb_globals.g_tree_st_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_serial_number',
                              inv_mwb_globals.g_tree_serial_number
                              );
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END serial_node_event;

   PROCEDURE make_common_queries(p_flag IN VARCHAR2) IS
      l_procedure_name VARCHAR2(30);
   BEGIN
      l_procedure_name := 'MAKE_COMMON_QUERIES';

      CASE p_flag
      WHEN 'MOQD' THEN

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
            'moqd.organization_id';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                     'moqd.transaction_uom_code';

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

         inv_mwb_query_manager.add_group_clause('moqd.organization_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.transaction_uom_code', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.secondary_uom_code', 'ONHAND');

      WHEN 'MSN_QUERY' THEN

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
            'msn.current_organization_id';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
            '''Ea''';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value := 1;

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
            'SUM(DECODE(msn.lpn_id, NULL, 0,1))';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
            'SUM(DECODE(msn.lpn_id, NULL, 1,0))';

         inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');

         inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('''Ea''', 'ONHAND');


      WHEN 'MSN' THEN

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
            'msn.inventory_item_id';

	 inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
            'msn.current_subinventory_code'; --VARAJAGO

	 inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
            'msn.current_locator_id'; --VARAJAGO

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
            'msn.current_organization_id';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
            '''Ea''';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value := 1;

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
            'DECODE(msn.lpn_id, NULL, 0,1)';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
            'DECODE(msn.lpn_id, NULL, 1,0)';

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
             'msn.serial_number';

         inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');

      END CASE; -- p_flag

   END make_common_queries;
   --
   -- public functions
   --

   PROCEDURE event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'EVENT';

      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Entered');

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED'
      OR inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Tree Node Type: '||inv_mwb_globals.g_tree_node_type);

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
             WHEN 'SUB' THEN
                sub_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );
             WHEN 'LOC' THEN
                loc_node_event (
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
             WHEN 'SUB_FOLDER' THEN
                sub_folder_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );
             WHEN 'LOC_FOLDER' THEN
                loc_folder_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );
             WHEN 'LOT_FOLDER' THEN
                lot_folder_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );
             WHEN 'SERIAL_FOLDER' THEN
                serial_folder_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );
             WHEN 'STATUS' THEN
                status_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );

             -- Onhand Material Status support
             WHEN 'ONHAND_FOLDER' THEN
                onhand_node_event (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );

         END CASE;
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END event;

END INV_MWB_STATUS_TREE;

/
