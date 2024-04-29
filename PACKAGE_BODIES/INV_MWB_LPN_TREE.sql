--------------------------------------------------------
--  DDL for Package Body INV_MWB_LPN_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_LPN_TREE" AS
/* $Header: INVMWLPB.pls 120.14 2008/01/30 09:46:43 ammathew ship $ */
   --
   -- private functions
   --
   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_LPN_TREE';

   PROCEDURE make_common_query_onhand (p_flag VARCHAR2);
   PROCEDURE make_common_query_receiving (p_flag VARCHAR2);
   PROCEDURE make_common_query_lpn;

--   PROCEDURE make_common_query_lpn(p_flag VARCHAR2);

   PROCEDURE root_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);
   BEGIN

      l_procedure_name := 'ROOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_orgs (
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

        -- If all material locations are unchecked and the view by is LPN
        -- Using ONHAND but it does not query onhand material location.
         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0 THEN
            make_common_query_lpn;
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;

         IF inv_mwb_globals.g_chk_onhand = 1 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL
	       OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_query_onhand('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
            END IF;
         END IF;

         IF inv_mwb_globals.g_chk_receiving = 1 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL THEN
               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');
            ELSE
               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
            END IF;
         END IF;

         inv_mwb_query_manager.execute_query;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END root_node_event;

   PROCEDURE org_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR(30);
      TYPE tab IS TABLE OF varchar2(100) index by binary_integer;
      mtl_loc_type tab;
   BEGIN
      l_procedure_name := 'ORG_NODE_EVENT';
      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         SELECT meaning
         BULK COLLECT INTO mtl_loc_type
         FROM mfg_lookups
         WHERE lookup_type = 'MTL_LOCATION_TYPES'
         ORDER BY lookup_code;

         inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Selected all the document types' );

         IF inv_mwb_globals.g_chk_onhand = 0 AND
            inv_mwb_globals.g_chk_receiving = 0 AND
            inv_mwb_globals.g_chk_inbound = 0 THEN

               inv_mwb_tree1.add_lpns (
                    x_node_value
                  , x_node_tbl
                  , x_tbl_index
                  );

            RETURN;
          END IF;

            IF inv_mwb_globals.g_chk_onhand = 1
            THEN
             x_node_tbl(x_tbl_index).state := -1;
             x_node_tbl(x_tbl_index).DEPTH := 1;
             x_node_tbl(x_tbl_index).label := mtl_loc_type(1);
             x_node_tbl(x_tbl_index).icon := 'tree_workflowpackage';
             x_node_tbl(x_tbl_index).VALUE := 1;
             x_node_tbl(x_tbl_index).TYPE := 'MATLOC';
             x_tbl_index := x_tbl_index + 1;
            END IF;

            IF NVL(inv_mwb_globals.g_chk_receiving, 1) = 1
            THEN
            x_node_tbl(x_tbl_index).state := -1;
            x_node_tbl(x_tbl_index).DEPTH := 1;
            x_node_tbl(x_tbl_index).label := mtl_loc_type(2);
            x_node_tbl(x_tbl_index).icon := 'tree_workflowpackage';
            x_node_tbl(x_tbl_index).VALUE := 2;
            x_node_tbl(x_tbl_index).TYPE := 'MATLOC';
            x_tbl_index := x_tbl_index + 1;
            END IF;


      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

        -- If all material locations are unchecked and the view by is LPN
	     -- Using ONHAND but it does not query onhand material location.

         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0
         AND inv_mwb_globals.g_view_by = 'LPN' THEN
            make_common_query_lpn;
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'wlc.cost_group_id';

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlc.cost_group_id','ONHAND');

            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;

  	      IF inv_mwb_globals.g_chk_onhand = 1 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL THEN
               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','ONHAND');
            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id','ONHAND');

            END IF;
         END IF;

         IF inv_mwb_globals.g_chk_receiving = 1 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL THEN
               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','RECEIVING');

            ELSE
               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'rs.to_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rs.lpn_id';

               inv_mwb_query_manager.add_group_clause('rs.to_subinventory','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.to_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.lpn_id','RECEIVING');
            END IF;
         END IF;

         inv_mwb_query_manager.execute_query;
      END IF; -- Node selected
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END org_node_event;


   PROCEDURE mat_loc_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR(30);
   BEGIN
      l_procedure_name := 'MAT_LOC_NODE_EVENT';
      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_lpns (
                          x_node_value
                        , x_node_tbl
                        , x_tbl_index
                        );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

        -- If all material locations are unchecked and the view by is LPN
	-- Using ONHAND but it does not query onhand material location.
         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0
         AND inv_mwb_globals.g_view_by = 'LPN' THEN
            make_common_query_lpn;
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'wlc.cost_group_id';

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlc.cost_group_id','ONHAND');

            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;

         IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL
	       OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_query_onhand('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','ONHAND');
            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id','ONHAND');

            END IF;
         END IF;

         IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL THEN
               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','RECEIVING');

            ELSE
               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'rs.to_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rs.lpn_id';

               inv_mwb_query_manager.add_group_clause('rs.to_subinventory','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.to_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.lpn_id','RECEIVING');
            END IF;
         END IF;

         inv_mwb_query_manager.execute_query;
      END IF; --Tree node selected
   END mat_loc_node_event;

   PROCEDURE lpn_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);
   BEGIN

      l_procedure_name := 'LPN_NODE_EVENT';
      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Entered' );

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_lpns (
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

         inv_mwb_tree1.add_items (
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

        -- If all material locations are unchecked and the view by is LPN
	     -- Using ONHAND but it does not query onhand material location.
         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0
         AND inv_mwb_globals.g_view_by = 'LPN' THEN

            inv_mwb_query_manager.make_nested_lpn_onhand_query;

            make_common_query_lpn;
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'wlc.cost_group_id';

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlc.cost_group_id','ONHAND');

            inv_mwb_query_manager.add_where_clause('wlpn.lpn_id = :onh_lpn_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;

--         inv_mwb_query_manager.make_nested_lpn_onhand_query;

         IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL
	       OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

               inv_mwb_query_manager.make_nested_lpn_onhand_query;

               make_common_query_onhand('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

            ELSE

               inv_mwb_query_manager.make_nested_lpn_onhand_query;
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id','ONHAND');

               inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

            END IF;
         END IF;

         IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN

            inv_mwb_query_manager.make_nested_lpn_rcv_query;

            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL THEN
               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','RECEIVING');

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

            ELSE

               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'rs.to_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rs.lpn_id';

               inv_mwb_query_manager.add_group_clause('rs.to_subinventory','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.to_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.lpn_id','RECEIVING');

               inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

            END IF;
         END IF;
         inv_mwb_query_manager.execute_query;
      END IF;  -- Node selected
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END lpn_node_event;

   PROCEDURE item_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_rev_control    NUMBER;
      l_lot_control    NUMBER;
      l_serial_control NUMBER;
      l_procedure_name VARCHAR2(30);

      /* LPN Status Project */
      l_lot_controlled       NUMBER := 0;
      l_serial_controlled    NUMBER := 0;
      l_default_status_id    NUMBER;
      l_status_id            NUMBER;

   BEGIN

      l_procedure_name := 'ITEM_NODE_EVENT';

      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Item Node Event-Entered' );

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_revs (
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

         IF x_tbl_index = 1 THEN
            inv_mwb_tree1.add_lots (
                          x_node_value
                        , x_node_tbl
                        , x_tbl_index
                        );


            IF x_tbl_index = 1 THEN
               IF NVL(inv_mwb_globals.g_prepacked,-99) <> 10 THEN
                  inv_mwb_tree1.add_serials (
                                x_node_value
                              , x_node_tbl
                              , x_tbl_index
                              );


               END IF;
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
         AND    organization_id = inv_mwb_globals.g_organization_id;

        -- If all material locations are unchecked and the view by is LPN
	     -- Using ONHAND but it does not query onhand material location.
         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0
         AND inv_mwb_globals.g_view_by = 'LPN' THEN
	    make_common_query_lpn;
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'wlc.cost_group_id';
            IF l_rev_control = 2 THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'wlc.revision';
               inv_mwb_query_manager.add_group_clause('wlc.revision','ONHAND');
            ELSE
               IF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'wlc.lot_number';
                  inv_mwb_query_manager.add_group_clause('wlc.lot_number','ONHAND');
               ELSIF l_serial_control IN (2, 5) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                     'msn.serial_number';
                  inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');
               END IF;
            END IF;

	    /*LPN Status Project */
	    IF (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) THEN
                  l_default_status_id :=  inv_cache.org_rec.default_status_id;
            END IF;

            IF inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) THEN

	      IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                    l_serial_controlled := 1; -- Item is serial controlled
              END IF;

              IF (inv_cache.item_rec.lot_control_code <> 1) THEN
                    l_lot_controlled := 1; -- Item is lot controlled
              END IF;

            END IF;

            IF (l_default_status_id IS NOT NULL AND l_serial_controlled = 0 AND l_lot_controlled = 0) THEN

	      l_status_id := INV_MATERIAL_STATUS_GRP.get_default_status(p_organization_id => inv_mwb_globals.g_organization_id,
				p_inventory_item_id=>inv_mwb_globals.g_tree_item_id ,
				p_sub_code=>inv_mwb_globals.g_tree_subinventory_code,
				p_loc_id=>inv_mwb_globals.g_tree_loc_id,
				p_lot_number=>inv_mwb_globals.g_tree_lot_number,
				p_lpn_id=>inv_mwb_globals.g_tree_parent_lpn_id);

	      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Value of l_status_id:'|| l_status_id );

	      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                    l_status_id;
              inv_mwb_query_manager.add_group_clause(l_status_id, 'ONHAND');

            END IF;
            /* End of fix for LPN Status Project */

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlc.cost_group_id','ONHAND');

            inv_mwb_query_manager.add_where_clause('wlpn.lpn_id = :onh_lpn_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

            inv_mwb_query_manager.add_where_clause('wlc.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;



  	 IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN
            IF (inv_mwb_globals.g_serial_from IS NOT NULL OR
                inv_mwb_globals.g_serial_to IS NOT NULL)
               OR (NVL(l_rev_control, 1) = 1
                   AND NVL(l_lot_control, 1) = 1
                   AND l_serial_control IN ( 2,5 ))
	       OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

               make_common_query_onhand('MSN');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';

               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                     'msn.revision';
                  inv_mwb_query_manager.add_group_clause('msn.revision','ONHAND');
               ELSE
                  IF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'msn.lot_number';
                  inv_mwb_query_manager.add_group_clause('msn.lot_number','ONHAND');
                  ELSIF l_serial_control IN (2, 5) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                     'msn.serial_number';
                  inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');
                  END IF;
               END IF;

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';

               /* LPN Status Support */
               -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.

               inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'LPN Status check');

	       IF (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) THEN
                  l_default_status_id :=  inv_cache.org_rec.default_status_id;
               END IF;

               IF inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) THEN
                 IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                    l_serial_controlled := 1; -- Item is serial controlled
                 END IF;

                 IF (inv_cache.item_rec.lot_control_code <> 1) then
                    l_lot_controlled := 1; -- Item is lot controlled
                 END IF;
               END IF;

	       IF (l_default_status_id IS NOT NULL AND l_serial_controlled = 0 and l_lot_controlled = 0) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                  'moqd.status_id';
                  inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
               END IF;

	       /* LPN Status Support */

               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                     'moqd.revision';
                  inv_mwb_query_manager.add_group_clause('moqd.revision','ONHAND');
               ELSIF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'moqd.lot_number';
                  inv_mwb_query_manager.add_group_clause('moqd.lot_number','ONHAND');
               END IF;

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id','ONHAND');

               inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            END IF;
         END IF;

         IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL
               OR (NVL(l_rev_control, 1) = 1
                   AND NVL(l_lot_control, 1) = 1
                   AND l_serial_control IN ( 2,5 ))  THEN

               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','RECEIVING');

               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                     'msn.revision';
                  inv_mwb_query_manager.add_group_clause('msn.revision','RECEIVING');
               ELSE
                  IF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'msn.lot_number';
                  inv_mwb_query_manager.add_group_clause('msn.lot_number','RECEIVING');
                  ELSIF l_serial_control IN (2, 5) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                     'msn.serial_number';
                  inv_mwb_query_manager.add_group_clause('msn.serial_number','RECEIVING');
                  END IF;
               END IF;

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);


            ELSE
               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'rs.to_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rs.lpn_id';

               inv_mwb_query_manager.add_group_clause('rs.to_subinventory','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.to_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.lpn_id','RECEIVING');

               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                     'rs.item_revision';
                  inv_mwb_query_manager.add_group_clause('rs.item_revision','RECEIVING');
               ELSIF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'rls.lot_num';
                  inv_mwb_query_manager.add_group_clause('rls.lot_num','RECEIVING');
               END IF;

	       inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('rs.item_id = :onh_inventory_item_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            END IF;
         END IF;

         inv_mwb_query_manager.execute_query;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END item_node_event;

   PROCEDURE rev_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_lot_control    NUMBER;
      l_serial_control NUMBER;
      l_procedure_name VARCHAR2(30);

      /* LPN Status Project */
      l_lot_controlled       NUMBER := 0;
      l_serial_controlled    NUMBER := 0;
      l_default_status_id    NUMBER;
      l_status_id            NUMBER;

   BEGIN

      l_procedure_name := 'REV_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_lots (
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

         IF x_tbl_index = 1 THEN
            inv_mwb_tree1.add_serials (
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
         AND    organization_id = inv_mwb_globals.g_organization_id;

        -- If all material locations are unchecked and the view by is LPN
	     -- Using ONHAND but it does not query onhand material location.
         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0
         AND inv_mwb_globals.g_view_by = 'LPN' THEN
            make_common_query_lpn;
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'wlc.cost_group_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
               'wlc.revision';
            inv_mwb_query_manager.add_group_clause('wlc.revision','ONHAND');

            IF l_lot_control = 2 THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                  'wlc.lot_number';
               inv_mwb_query_manager.add_group_clause('wlc.lot_number','ONHAND');
            ELSIF l_serial_control IN (2, 5) THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                  'msn.serial_number';
               inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');
            END IF;

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlc.cost_group_id','ONHAND');

	    /*LPN Status Project */
	    IF (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) THEN
                  l_default_status_id :=  inv_cache.org_rec.default_status_id;
            END IF;

            IF inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) THEN

	      IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                    l_serial_controlled := 1; -- Item is serial controlled
              END IF;

              IF (inv_cache.item_rec.lot_control_code <> 1) THEN
                    l_lot_controlled := 1; -- Item is lot controlled
              END IF;

            END IF;

            IF (l_default_status_id IS NOT NULL AND l_serial_controlled = 0 AND l_lot_controlled = 0) THEN

	      l_status_id := INV_MATERIAL_STATUS_GRP.get_default_status(p_organization_id => inv_mwb_globals.g_organization_id,
				p_inventory_item_id=>inv_mwb_globals.g_tree_item_id ,
				p_sub_code=>inv_mwb_globals.g_tree_subinventory_code,
				p_loc_id=>inv_mwb_globals.g_tree_loc_id,
				p_lot_number=>inv_mwb_globals.g_tree_lot_number,
				p_lpn_id=>inv_mwb_globals.g_tree_parent_lpn_id);

	      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Value of l_status_id:'|| l_status_id );

	      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                    l_status_id;
              inv_mwb_query_manager.add_group_clause(l_status_id, 'ONHAND');

            END IF;
            /* End of fix for LPN Status Project */

            inv_mwb_query_manager.add_where_clause('wlc.revision = :onh_revision', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);


            inv_mwb_query_manager.add_where_clause('wlpn.lpn_id = :onh_lpn_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;

  	 IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN
            IF (inv_mwb_globals.g_serial_from IS NOT NULL OR
                inv_mwb_globals.g_serial_to IS NOT NULL)
               OR (NVL(l_lot_control, 1) = 1
                   AND l_serial_control IN ( 2,5 ))
	       OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_query_onhand('MSN');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'msn.revision';
               inv_mwb_query_manager.add_group_clause('msn.revision','ONHAND');

               IF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'msn.lot_number';
                  inv_mwb_query_manager.add_group_clause('msn.lot_number','ONHAND');
               ELSIF l_serial_control IN (2, 5) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                     'msn.serial_number';
                  inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');
               END IF;

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);
               inv_mwb_query_manager.add_where_clause('msn.revision = :onh_revision', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);


            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'moqd.revision';
               inv_mwb_query_manager.add_group_clause('moqd.revision','ONHAND');

               IF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'moqd.lot_number';
                  inv_mwb_query_manager.add_group_clause('moqd.lot_number','ONHAND');
               END IF;

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id','ONHAND');

		/* LPN Status Project */
		-- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.
		IF (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) THEN
 	          l_default_status_id :=  inv_cache.org_rec.default_status_id;
		END IF;

		IF inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) THEN
		  IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
			 l_serial_controlled := 1; -- Item is serial controlled
		  END IF;

		  IF (inv_cache.item_rec.lot_control_code <> 1) THEN
			 l_lot_controlled := 1; -- Item is lot controlled
		  END IF;
		END IF;

		IF (l_default_status_id IS NOT NULL AND l_serial_controlled = 0 AND l_lot_controlled = 0) THEN
		    inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
		    'moqd.status_id';
		    inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
		END IF;

	       /* LPN Status Project */

               inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);
               inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_revision', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);

            END IF;
         END IF;

         IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL
               OR (NVL(l_lot_control, 1) = 1
                   AND l_serial_control IN ( 2,5 ))  THEN

               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','RECEIVING');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'msn.revision';
               inv_mwb_query_manager.add_group_clause('msn.revision','RECEIVING');

               IF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'msn.lot_number';
                  inv_mwb_query_manager.add_group_clause('msn.lot_number','RECEIVING');
               ELSIF l_serial_control IN (2, 5) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                     'msn.serial_number';
                  inv_mwb_query_manager.add_group_clause('msn.serial_number','RECEIVING');
               END IF;

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.revision = :onh_revision', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            ELSE

               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'rs.to_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rs.lpn_id';

               inv_mwb_query_manager.add_group_clause('rs.to_subinventory','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.to_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.lpn_id','RECEIVING');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'rs.item_revision';
               inv_mwb_query_manager.add_group_clause('rs.item_revision','RECEIVING');

               IF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                     'rls.lot_num';
                  inv_mwb_query_manager.add_group_clause('rls.lot_num','RECEIVING');
               END IF;

               inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('rs.item_revision = :onh_revision', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               inv_mwb_query_manager.add_where_clause('rs.item_id = :onh_inventory_item_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            END IF;
         END IF;
         inv_mwb_query_manager.execute_query;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END rev_node_event;

   PROCEDURE lot_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_serial_control NUMBER;
      l_procedure_name VARCHAR2(30);

      /* LPN Status Project */
      l_serial_controlled    NUMBER := 0;
      l_default_status_id    NUMBER;
      l_status_id            NUMBER;

   BEGIN

      l_procedure_name := 'LOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_serials  (
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index);

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT serial_number_control_code
         INTO   l_serial_control
         FROM   mtl_system_items
         WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
         AND    organization_id = inv_mwb_globals.g_organization_id;

         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0 THEN
            make_common_query_lpn;
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'wlc.cost_group_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
               'wlc.revision';
            inv_mwb_query_manager.add_group_clause('wlc.revision','ONHAND');

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
               'wlc.lot_number';
            inv_mwb_query_manager.add_group_clause('wlc.lot_number','ONHAND');

            IF l_serial_control IN (2, 5) THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                  'msn.serial_number';
               inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');
            END IF;

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlc.cost_group_id','ONHAND');

	    /* LPN Status Project */
            -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.

	    inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'org id' ||inv_mwb_globals.g_tree_organization_id );

            IF(inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) THEN
	      l_default_status_id :=  inv_cache.org_rec.default_status_id;
            END IF;

	    inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'org status id' || l_default_status_id);

            IF inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) THEN
              IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                l_serial_controlled := 1; -- Item is serial controlled
              END IF;
            END IF;

            IF (l_default_status_id is not null and l_serial_controlled = 0) THEN

              l_status_id := INV_MATERIAL_STATUS_GRP.get_default_status(p_organization_id => inv_mwb_globals.g_organization_id,
		   	        p_inventory_item_id=>inv_mwb_globals.g_tree_item_id ,
				p_sub_code=>inv_mwb_globals.g_tree_subinventory_code,
				p_loc_id=>inv_mwb_globals.g_tree_loc_id,
				p_lot_number=>inv_mwb_globals.g_tree_lot_number,
				p_lpn_id=>inv_mwb_globals.g_tree_parent_lpn_id);

	       inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Value of l_status_id:'|| l_status_id );

	       inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                     l_status_id;
               inv_mwb_query_manager.add_group_clause(l_status_id, 'ONHAND');

            END IF;
            /* End of fix for LPN Status Project */

            inv_mwb_query_manager.add_where_clause('wlpn.lpn_id = :onh_lpn_id', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('wlc.lot_number = :onh_lot_number', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_lot_number', inv_mwb_globals.g_tree_lot_number);
            inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;

  	 IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN
            IF (inv_mwb_globals.g_serial_from IS NOT NULL OR
                inv_mwb_globals.g_serial_to IS NOT NULL)
               OR l_serial_control IN ( 2,5 )
	       OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_query_onhand('MSN');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'msn.revision';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                  'msn.lot_number';


               IF l_serial_control IN (2, 5) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                     'msn.serial_number';
                  inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');
               END IF;

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.revision','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lot_number','ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

               IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('msn.revision = :onh_revision', 'ONHAND');
                  inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               END IF;
            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'moqd.revision';
               inv_mwb_query_manager.add_group_clause('moqd.revision','ONHAND');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                  'moqd.lot_number';
               inv_mwb_query_manager.add_group_clause('moqd.lot_number','ONHAND');

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id','ONHAND');

	       /* LPN Status Project */
               -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.

	       inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'org id' ||inv_mwb_globals.g_tree_organization_id );

               IF(inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) THEN
	         l_default_status_id :=  inv_cache.org_rec.default_status_id;
               END IF;

	       inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'org status id' || l_default_status_id);

               IF inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) THEN
                 IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                   l_serial_controlled := 1; -- Item is serial controlled
                 END IF;
               END IF;

               inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'serial controlled' || l_serial_controlled);

               IF (l_default_status_id is not null and l_serial_controlled = 0) THEN
                 inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                 'moqd.status_id';
                 inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
               END IF;
               /* LPN Status Project */

               inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);
               inv_mwb_query_manager.add_where_clause('moqd.lot_number = :onh_lot_number', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lot_number', inv_mwb_globals.g_tree_lot_number);
               IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_revision', 'ONHAND');
                  inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               END IF;
            END IF;
         END IF;

         IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN
            IF (inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL)
               OR l_serial_control IN ( 2,5 ) THEN

               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','RECEIVING');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'msn.revision';
               inv_mwb_query_manager.add_group_clause('msn.revision','RECEIVING');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                  'msn.lot_number';
               inv_mwb_query_manager.add_group_clause('msn.lot_number','RECEIVING');

               IF l_serial_control IN (2, 5) THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                     'msn.serial_number';
                  inv_mwb_query_manager.add_group_clause('msn.serial_number','RECEIVING');
               END IF;

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.lot_number = :onh_lot_number', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_lot_number', inv_mwb_globals.g_tree_lot_number);

               IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('msn.revision = :onh_revision', 'RECEIVING');
                  inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               END IF;
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            ELSE

               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'rs.to_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rs.lpn_id';

               inv_mwb_query_manager.add_group_clause('rs.to_subinventory','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.to_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.lpn_id','RECEIVING');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'rs.item_revision';
               inv_mwb_query_manager.add_group_clause('rs.item_revision','RECEIVING');


               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                  'rls.lot_num';
               inv_mwb_query_manager.add_group_clause('rls.lot_num','RECEIVING');


               inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('rs.item_revision = :onh_revision', 'RECEIVING');
                  inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               END IF;
               inv_mwb_query_manager.add_where_clause('rls.lot_number = :onh_lot_number', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_lot_number', inv_mwb_globals.g_tree_lot_number);

               inv_mwb_query_manager.add_where_clause('rs.item_id = :onh_inventory_item_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);

            END IF;
         END IF;

         inv_mwb_query_manager.execute_query;
   END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
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
         IF inv_mwb_globals.g_chk_onhand = 0
         AND inv_mwb_globals.g_chk_receiving = 0
         AND inv_mwb_globals.g_chk_inbound = 0
         AND inv_mwb_globals.g_view_by = 'LPN' THEN
            make_common_query_lpn;
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'wlc.cost_group_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
               'wlc.revision';
            inv_mwb_query_manager.add_group_clause('wlc.revision','ONHAND');

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
               'wlc.lot_number';
            inv_mwb_query_manager.add_group_clause('wlc.lot_number','ONHAND');

            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
               'msn.serial_number';
            inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id','ONHAND');
            inv_mwb_query_manager.add_group_clause('wlc.cost_group_id','ONHAND');

            inv_mwb_query_manager.add_where_clause('wlpn.lpn_id = :onh_lpn_id', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.serial_number = :onh_serial_number', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_serial_number', inv_mwb_globals. g_tree_serial_number);
            inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            inv_mwb_query_manager.add_qf_where_lpn_node('ONHAND');
            inv_mwb_query_manager.execute_query;
            RETURN;
   	   END IF;

	   IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN
              make_common_query_onhand('MSN');
              inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                  'msn.revision';
               inv_mwb_query_manager.add_group_clause('msn.revision','ONHAND');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                  'msn.lot_number';
               inv_mwb_query_manager.add_group_clause('msn.lot_number','ONHAND');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                  'msn.serial_number';
               inv_mwb_query_manager.add_group_clause('msn.serial_number','ONHAND');

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);
               inv_mwb_query_manager.add_where_clause('msn.serial_number = :onh_serial_number', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_serial_number', inv_mwb_globals. g_tree_serial_number);

               IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('msn.revision = :onh_revision', 'ONHAND');
                  inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               END IF;
               IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('msn.lot_number = :onh_lot_number', 'ONHAND');
                  inv_mwb_query_manager.add_bind_variable('onh_lot_number', inv_mwb_globals.g_tree_lot_number);
               END IF;
            END IF;

            IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN
               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN_RECEIVING');

               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.REVISION).column_value :=
                  'msn.revision';
               inv_mwb_query_manager.add_group_clause('msn.revision','RECEIVING');

               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
                  'msn.lot_number';
               inv_mwb_query_manager.add_group_clause('msn.lot_number','RECEIVING');

               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SERIAL).column_value :=
                  'msn.serial_number';
               inv_mwb_query_manager.add_group_clause('msn.serial_number','RECEIVING');

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id','RECEIVING');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id','RECEIVING');

               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_tree_item_id);
               inv_mwb_query_manager.add_where_clause('msn.serial_number = :onh_serial_number', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('onh_serial_number', inv_mwb_globals. g_tree_serial_number);

               IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('msn.revision = :onh_revision', 'RECEIVING');
                  inv_mwb_query_manager.add_bind_variable('onh_revision', inv_mwb_globals.g_tree_rev);
               END IF;
               IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause('msn.lot_number = :onh_lot_number', 'RECEIVING');
                  inv_mwb_query_manager.add_bind_variable('onh_lot_number', inv_mwb_globals.g_tree_lot_number);
               END IF;
            END IF;

      inv_mwb_query_manager.execute_query;

      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END serial_node_event;

   --
   -- public functions
   --

   --
   -- General APPTREE event handler for the EMPLOYEE tab.
   --


   PROCEDURE make_common_query_onhand(p_flag VARCHAR2) IS
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

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value := 1;


               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value := 0;

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
                  'NULL';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_PACKED).column_value :=
                  'NULL';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UNPACKED).column_value :=
                  'NULL';

--               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
---                  'msn.serial_number';

               inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');

               inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('''Ea''', 'ONHAND');
--               inv_mwb_query_manager.add_group_clause('msn.serial_number', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.lpn_id IS NOT NULL', 'ONHAND');

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
                  'SUM(moqd.primary_transaction_quantity)';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value := 0;

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
                  'moqd.secondary_uom_code';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_ONHAND).column_value :=
                  'SUM(moqd.secondary_transaction_quantity)';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_PACKED).column_value :=
                  'SUM(moqd.secondary_transaction_quantity)';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UNPACKED).column_value := 0;


               inv_mwb_query_manager.add_from_clause('mtl_onhand_quantities_detail moqd', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('moqd.lpn_id IS NOT NULL', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.organization_id', 'ONHAND');
--               inv_mwb_query_manager.add_group_clause('moqd.transaction_uom_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.secondary_uom_code', 'ONHAND');

            WHEN 'MSN_QUERY' THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
                                       'count(1)';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                                       'count(1)';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value := 0;

               inv_mwb_query_manager.add_group_clause('msn.inventory_item_id' , 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('''Ea''', 'ONHAND');

               inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.lpn_id IS NOT NULL', 'ONHAND');
         END CASE; -- p_flag
      END IF;
   END;

   PROCEDURE make_common_query_receiving(p_flag VARCHAR2) IS
        l_procedure_name VARCHAR2(30);
   BEGIN
      l_procedure_name := 'MAKE_COMMON_QUERY_RECEIVING';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'p_flag : ' || p_flag);
      IF(inv_mwb_globals.g_chk_receiving = 1) THEN
         IF p_flag = 'RECEIVING' THEN
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'rs.to_organization_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ITEM_ID).column_value :=
               'rs.item_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.RECEIVING).column_value :=
               'SUM(rs.to_org_primary_quantity)';

            inv_mwb_query_manager.add_group_clause('rs.to_organization_id','RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.item_id','RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.lpn_id IS NOT NULL', 'RECEIVING');


            IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
            OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.UNPACKED).column_value := 0;
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PACKED).column_value :=
               'SUM(rs.to_org_primary_quantity)';
            END IF;

         ELSIF p_flag = 'RCV_TREE_LPN' THEN

            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'wlpn.organization_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ITEM_ID).column_value :=
               'wlc.inventory_item_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
               'wlc.uom_code';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.RECEIVING).column_value :=
               'SUM(wlc.primary_quantity)';--bug 4761399

            inv_mwb_query_manager.add_group_clause('wlpn.organization_id','RECEIVING');
            inv_mwb_query_manager.add_group_clause('wlc.inventory_item_id','RECEIVING');
            inv_mwb_query_manager.add_group_clause('wlc.uom_code','RECEIVING');

   	      IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
            OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
                  'wlc.secondary_uom_code';
               inv_mwb_query_manager.add_group_clause('wlc.secondary_uom_code','RECEIVING');
            END IF;

         ELSIF p_flag = 'MSN' THEN

            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ITEM_ID).column_value :=
               'msn.inventory_item_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'msn.current_organization_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
               '''Ea''';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.receiving).column_value := 1;

            inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('''Ea''', 'RECEIVING');

            IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
            OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PACKED).column_value := 1;
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.UNPACKED).column_value := 0;
            END IF;

         ELSIF p_flag = 'MSN_QUERY' THEN
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ITEM_ID).column_value :=
               'msn.inventory_item_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'msn.current_organization_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
               '''Ea''';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.receiving).column_value :=
               'count(1)';
            inv_mwb_query_manager.add_group_clause('msn.inventory_item_id' , 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('''Ea''', 'RECEIVING');

            IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
            OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PACKED).column_value :=
                  'count(1)';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.UNPACKED).column_value := 0;
            END IF;
      END IF;
   END IF; -- End if for receiving
   END make_common_query_receiving;


   PROCEDURE make_common_query_lpn
   IS
   BEGIN
      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
      'wlpn.organization_id';
      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
      'wlc.inventory_item_id';
      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
      'wlc.uom_code';
      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
      'wlc.secondary_uom_code';
      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
      'SUM(wlc.primary_quantity)'; --bug 4761399

--      IF inv_mwb_globals.g_prepacked <> 12 THEN -- For All states chosen dont add this where clause.   -- Bug : 6023196
      IF inv_mwb_globals.g_prepacked <> 999 THEN -- For All states chosen dont add this where clause.   -- Bug : 6023196
         inv_mwb_query_manager.add_where_clause('wlpn.lpn_context = :onh_lpn_context', 'ONHAND');
         inv_mwb_query_manager.add_bind_variable('onh_lpn_context', inv_mwb_globals.g_prepacked);
      END IF;

      inv_mwb_query_manager.add_group_clause('wlpn.organization_id','ONHAND');
      inv_mwb_query_manager.add_group_clause('wlc.inventory_item_id','ONHAND');
      inv_mwb_query_manager.add_group_clause('wlc.uom_code','ONHAND');
      inv_mwb_query_manager.add_group_clause('wlc.secondary_uom_code','ONHAND');
   END;

  PROCEDURE event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_procedure_name VARCHAR2(30);
   BEGIN

      l_procedure_name := 'EVENT';
      x_tbl_index := 1;
      x_node_value := 1;

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED'
      OR inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         CASE  inv_mwb_globals.g_tree_node_type
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

            WHEN 'MATLOC' THEN
               mat_loc_node_event (
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

            WHEN 'LPN' THEN
               lpn_node_event (
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
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END event;

END INV_MWB_LPN_TREE;

/
