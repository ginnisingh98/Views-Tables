--------------------------------------------------------
--  DDL for Package Body INV_MWB_COST_GROUP_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_COST_GROUP_TREE" AS
/* $Header: INVMWCGB.pls 120.8 2008/01/10 23:17:50 musinha ship $ */

   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_COST_GROUP_TREE';

   -- PROCEDURE make_common_queries(p_flag VARCHAR2); -- Bug 6060233
   --
   -- private functions
   --
   PROCEDURE root_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ROOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_cgs(
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

      END IF; -- event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END root_node_event;

   PROCEDURE cost_group_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'COST_GROUP_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_orgs(
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
            inv_mwb_query_manager.add_where_clause('msn.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.add_where_clause('moqd.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
         inv_mwb_query_manager.add_bind_variable('onh_tree_cost_group_id', inv_mwb_globals.g_tree_cg_id);
         inv_mwb_query_manager.execute_query;

      END IF; -- event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END cost_group_node_event;

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

         IF inv_mwb_globals.g_serial_from IS NOT NULL OR
            inv_mwb_globals.g_serial_to IS NOT NULL
            OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.add_where_clause('msn.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id' ,'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.add_where_clause('moqd.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
         inv_mwb_query_manager.add_bind_variable('onh_tree_cost_group_id', inv_mwb_globals.g_tree_cg_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
         inv_mwb_query_manager.execute_query;

      END IF; -- tree event

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
      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         IF inv_mwb_globals.g_serial_from IS NOT NULL OR
            inv_mwb_globals.g_serial_to IS NOT NULL
            OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_queries('MSN_QUERY');
            inv_mwb_query_manager.add_where_clause('msn.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_queries('MOQD');
            inv_mwb_query_manager.add_where_clause('moqd.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
         inv_mwb_query_manager.add_bind_variable('onh_tree_cost_group_id', inv_mwb_globals.g_tree_cg_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END item_node_event;

   PROCEDURE make_common_queries(p_flag VARCHAR2) IS
   BEGIN

      IF(inv_mwb_globals.g_chk_onhand = 1) THEN

         CASE p_flag
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

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';

               inv_mwb_query_manager.add_from_clause('mtl_onhand_quantities_detail moqd', 'ONHAND');

               inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.organization_id', 'ONHAND');
--               inv_mwb_query_manager.add_group_clause('moqd.transaction_uom_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.secondary_uom_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');

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
                                       'count(decode(msn.lpn_id,NULL,0, 1))';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                                       'count(decode(msn.lpn_id,NULL,1, 0))';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.COST_GROUP).column_value :=
                                       'msn.cost_group_id';
               inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.inventory_item_id' , 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('''Ea''', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id', 'ONHAND');
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

            WHEN 'COST_GROUP' THEN
               cost_group_node_event (
                        x_node_value
                      , x_node_tbl
                      , x_tbl_index
                      );

         END CASE;

      END IF; -- event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END event;

END inv_mwb_cost_group_tree;

/
