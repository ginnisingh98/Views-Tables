--------------------------------------------------------
--  DDL for Package Body INV_MWB_SERIAL_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_SERIAL_TREE" AS
/* $Header: INVMWSEB.pls 120.3 2005/07/18 10:59:48 rsagar noship $ */

   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_SERIAL_TREE';

   --
   -- private functions
   --
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
         inv_mwb_tree1.add_orgs(
                      x_node_value
                    , x_node_tbl
                    , x_tbl_index
                    );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         make_common_queries('MSN_QUERY');
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         inv_mwb_query_manager.execute_query;

      END IF; -- tree event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END root_node_event;

   PROCEDURE org_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

     l_procedure_name VARCHAR2(30);

  BEGIN

     l_procedure_name := 'ORG_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_serials(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         make_common_queries('MSN');
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                                       'msn.serial_number';
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id' ,
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         inv_mwb_query_manager.execute_query;

      END IF; -- g_tree_event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END org_node_event;

   PROCEDURE serial_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

     l_procedure_name VARCHAR2(30);

  BEGIN

     l_procedure_name := 'SERIAL_NODE_EVENT';

     IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
        inv_mwb_tree1.add_items(
                      x_node_value
                    , x_node_tbl
                    , x_tbl_index
                    );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         make_common_queries('MSN');
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                                       'msn.serial_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                       'msn.inventory_item_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                       'msn.current_subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                       'msn.current_locator_id';
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.serial_number = :onh_tree_serial_number' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id' ,
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_serial_number' ,
                              inv_mwb_globals.g_tree_serial_number
                              );
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         inv_mwb_query_manager.execute_query;

      END IF; -- g_tree_event

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END serial_node_event;

   PROCEDURE item_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS
      l_rev_control    NUMBER;
      l_lot_control    NUMBER;
      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'ITEM_NODE_EVENT';

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
         END IF;

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT revision_qty_control_code,
                lot_control_code
         INTO   l_rev_control,
                l_lot_control
         FROM   mtl_system_items
         WHERE  organization_id = inv_mwb_globals.g_tree_organization_id
         AND    inventory_item_id = inv_mwb_globals.g_tree_item_id;

         make_common_queries('MSN');
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                                       'msn.serial_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                       'msn.inventory_item_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                       'msn.current_subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                       'msn.current_locator_id';
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.serial_number = :onh_tree_serial_number' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id' ,
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_serial_number' ,
                              inv_mwb_globals.g_tree_serial_number
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_inventory_item_id' ,
                              inv_mwb_globals.g_tree_item_id
                              );

         IF l_rev_control = 1 AND l_lot_control = 2 THEN
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'msn.lot_number';
         END IF;
         IF l_rev_control = 2 THEN
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'msn.revision';
         END IF;
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         inv_mwb_query_manager.execute_query;

      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END item_node_event;

   PROCEDURE rev_node_event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

      l_lot_control    NUMBER;
      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'REV_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_lots(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT lot_control_code
         INTO   l_lot_control
         FROM   mtl_system_items
         WHERE  organization_id = inv_mwb_globals.g_tree_organization_id
         AND    inventory_item_id = inv_mwb_globals.g_tree_item_id;

         make_common_queries('MSN');
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                                       'msn.serial_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                       'msn.inventory_item_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                       'msn.current_subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                       'msn.current_locator_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'msn.revision';
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.serial_number = :onh_tree_serial_number' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.revision = :onh_tree_revision' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id' ,
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_serial_number' ,
                              inv_mwb_globals.g_tree_serial_number
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_inventory_item_id' ,
                              inv_mwb_globals.g_tree_item_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_revision' ,
                              inv_mwb_globals.g_tree_rev
                              );

         IF l_lot_control = 2 THEN
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'msn.lot_number';
         END IF;
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
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

      l_rev_control    NUMBER;
      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'LOT_NODE_EVENT';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         SELECT revision_qty_control_code
         INTO   l_rev_control
         FROM   mtl_system_items
         WHERE  organization_id = inv_mwb_globals.g_tree_organization_id
         AND    inventory_item_id = inv_mwb_globals.g_tree_item_id;

         make_common_queries('MSN');
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
                                       'msn.serial_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                                       'msn.inventory_item_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                                       'msn.current_subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                                       'msn.current_locator_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'msn.lot_number';
         inv_mwb_query_manager.add_where_clause(
                              'msn.current_organization_id = :onh_tree_organization_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.serial_number = :onh_tree_serial_number' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_where_clause(
                              'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                              'ONHAND'
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id' ,
                              inv_mwb_globals.g_tree_organization_id
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_serial_number' ,
                              inv_mwb_globals.g_tree_serial_number
                              );
         inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_inventory_item_id' ,
                              inv_mwb_globals.g_tree_item_id
                              );

         IF l_rev_control = 2 THEN
            inv_mwb_query_manager.add_where_clause(
                                 'msn.revision = :onh_tree_revision' ,
                                 'ONHAND'
                              );
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                       'msn.revision';
            inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_revision' ,
                                 inv_mwb_globals.g_tree_rev
                                 );
         END IF;
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         inv_mwb_query_manager.execute_query;

      END IF;
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END lot_node_event;

   PROCEDURE make_common_queries(p_flag VARCHAR2) IS
   BEGIN

      IF p_flag = 'MSN_QUERY' THEN
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
                                       'msn.current_organization_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
                                       'count(1)';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                                       'sum(decode(msn.lpn_id,NULL,0, 1))';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                                       'sum(decode(msn.lpn_id,NULL,1, 0))';
         inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn' , 'ONHAND');
         inv_mwb_query_manager.add_where_clause('msn.current_status = 3' , 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.current_organization_id' , 'ONHAND');
      ELSIF p_flag = 'MSN' THEN
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
                                       'msn.current_organization_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
                                       '1';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                                       'decode(msn.lpn_id,NULL,0, 1)';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                                       'decode(msn.lpn_id,NULL,1, 0)';
         inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn' , 'ONHAND');
         inv_mwb_query_manager.add_where_clause('msn.current_status = 3' , 'ONHAND');

      END IF;

   END make_common_queries;

   --
   -- public functions
   --

   --
   -- General APPTREE event handler for the EMPLOYEE tab.
   --
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

     END IF; -- node type

  EXCEPTION
     WHEN no_data_found THEN
        NULL;
  END event;

END INV_MWB_SERIAL_TREE;

/
