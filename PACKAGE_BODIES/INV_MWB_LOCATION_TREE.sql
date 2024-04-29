--------------------------------------------------------
--  DDL for Package Body INV_MWB_LOCATION_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_LOCATION_TREE" AS
/* $Header: INVMWLEB.pls 120.50.12010000.11 2009/11/05 08:10:26 kjujjuru ship $ */

  g_pkg_name VARCHAR2(30) := 'INV_MWB_LOCATION_TREE';

  -- PROCEDURE make_common_query_onhand(p_flag VARCHAR2); -- Bug 6060233 : Putting the declaration in the package spec.
  PROCEDURE make_common_query_receiving(p_flag VARCHAR2);
  PROCEDURE make_common_query_inbound(p_flag VARCHAR2);

   PROCEDURE root_node_event (
                          x_node_value IN OUT NOCOPY NUMBER
                        , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
                        , x_tbl_index  IN OUT NOCOPY NUMBER
                        ) IS
      i                NUMBER;
      j                NUMBER;
      l_procedure_name VARCHAR2(30);

   BEGIN

   l_procedure_name := 'ROOT_NODE_EVENT';
   inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Entered' );

   i                := x_tbl_index;
   j                := x_node_value;


      IF inv_mwb_globals.g_tree_event  = 'TREE_NODE_EXPANDED' THEN

         inv_mwb_tree1.add_orgs(
                       x_node_value
                     , x_node_tbl
                     , x_tbl_index
                     );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

      IF( inv_mwb_globals.g_chk_onhand = 1) THEN

         IF inv_mwb_globals.g_serial_from IS NOT NULL
         OR inv_mwb_globals.g_serial_to IS NOT NULL
         OR inv_mwb_globals.g_status_id IS NOT NULL
	 OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

            make_common_query_onhand('MSN_QUERY');

            IF inv_mwb_globals.g_detailed = 1 THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
               'msn.revision';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.revision', 'ONHAND');
            END IF;
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_query_onhand('MOQD');
            IF inv_mwb_globals.g_detailed = 1 THEN
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
               'moqd.revision';

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
            END IF;
            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;

      END IF;

      IF( inv_mwb_globals.g_chk_inbound = 1) THEN
         inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
         make_common_query_inbound('INBOUND');
      END IF;

      IF( inv_mwb_globals.g_chk_receiving = 1) THEN
         IF inv_mwb_globals.g_serial_from IS NOT NULL OR
         inv_mwb_globals.g_serial_to IS NOT NULL THEN
            make_common_query_receiving('MSN_QUERY');
            inv_mwb_query_manager.add_qf_where_receiving('MSN');
         ELSE
            make_common_query_receiving('RECEIVING');
            IF inv_mwb_globals.g_detailed = 1 THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'rs.to_locator_id';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.REVISION).column_value :=
               'rs.item_revision';

               inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
               inv_mwb_query_manager.add_group_clause('rs.item_revision', 'RECEIVING');
            END IF;
            inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
            END IF;
         END IF;
         inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Going to call execute_query');
         inv_mwb_query_manager.execute_query;
      END IF;

  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END root_node_event;


  PROCEDURE org_node_event(
    x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
  )
  IS
    i                    NUMBER                                                := 1;
    j                    NUMBER                                                := 1;
   TYPE tab IS TABLE OF varchar2(100) index by binary_integer;
   mtl_loc_type tab;
   str_query          varchar2(4000);
   l_procedure_name VARCHAR2(30);
  BEGIN

   l_procedure_name := 'ORG_NODE_EVENT';
   inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Entered' );

   IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

      SELECT meaning
      BULK COLLECT INTO mtl_loc_type
      FROM mfg_lookups
      WHERE lookup_type = 'MTL_LOCATION_TYPES'
      ORDER BY lookup_code;

   inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Selected all the document types' );

      IF inv_mwb_globals.g_chk_onhand = 1
      THEN
        x_node_tbl(i).state := -1;
        x_node_tbl(i).DEPTH := 1;
        x_node_tbl(i).label := mtl_loc_type(1);
        x_node_tbl(i).icon := 'tree_workflowpackage';
        x_node_tbl(i).VALUE := 1;
        x_node_tbl(i).TYPE := 'MATLOC';
        i := i + 1;
      END IF;

      IF NVL(inv_mwb_globals.g_chk_receiving, 1) = 1
      THEN
        x_node_tbl(i).state := -1;
        x_node_tbl(i).DEPTH := 1;
        x_node_tbl(i).label := mtl_loc_type(2);
        x_node_tbl(i).icon := 'tree_workflowpackage';
        x_node_tbl(i).VALUE := 2;
        x_node_tbl(i).TYPE := 'MATLOC';
        i := i + 1;
      END IF;

      IF inv_mwb_globals.g_chk_inbound = 1
      THEN
         x_node_tbl(i).state := -1;
         x_node_tbl(i).DEPTH := 1;
         x_node_tbl(i).label := mtl_loc_type(3);
         x_node_tbl(i).icon := 'tree_workflowpackage';
         x_node_tbl(i).VALUE := 3;
         x_node_tbl(i).TYPE := 'MATLOC';
         i := i + 1;
      END IF;


   ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Tree Node Selected' );

         IF(inv_mwb_globals.g_chk_onhand = 1) THEN
            IF (inv_mwb_globals.g_serial_from IS NOT NULL  ---serials entered in qf
            OR  inv_mwb_globals.g_serial_to IS NOT NULL)
            OR inv_mwb_globals.g_status_id IS NOT NULL  -- Bug 6060233
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_query_onhand('MSN_QUERY');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
            END IF;
         END IF;

         IF(inv_mwb_globals.g_chk_receiving = 1) THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL OR
               inv_mwb_globals.g_serial_to IS NOT NULL THEN
               make_common_query_receiving('MSN_QUERY');
               inv_mwb_query_manager.add_qf_where_receiving('MSN');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
               inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            ELSE
               make_common_query_receiving('RECEIVING');
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'rs.to_subinventory';
               inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
               inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
            END IF;
         END IF;

         IF(inv_mwb_globals.g_chk_inbound = 1) THEN
            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
         END IF;
         inv_mwb_query_manager.execute_query;
      END IF; -- tree event
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END org_node_event;


   PROCEDURE sub_node_event(
                         x_node_value          IN OUT NOCOPY NUMBER
                        ,x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
                        ,x_tbl_index           IN OUT NOCOPY NUMBER
                        )
   IS

   is_locator_controlled  BOOLEAN;
   loc_type               NUMBER;
   str_query              VARCHAR2(4000);
   l_procedure_name       VARCHAR2(30);

   BEGIN

      x_tbl_index           := 1;
      x_node_value          := 1;
      is_locator_controlled := FALSE;
      l_procedure_name      := 'SUB_NODE_EVENT';


      IF (inv_mwb_globals.g_locator_control_code = 2
         OR inv_mwb_globals.g_locator_control_code = 3) THEN
            is_locator_controlled := TRUE;
      ELSIF (inv_mwb_globals.g_locator_control_code = 1) THEN
         is_locator_controlled := FALSE;
      ELSIF (inv_mwb_globals.g_locator_control_code = 4)
      AND inv_mwb_globals.g_tree_organization_id IS NOT NULL
      AND inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN

         SELECT locator_type
         INTO   loc_type
         FROM   mtl_secondary_inventories
         WHERE  secondary_inventory_name = inv_mwb_globals.g_tree_subinventory_code
         AND    organization_id = inv_mwb_globals.g_tree_organization_id;

      IF loc_type = 1 THEN
         is_locator_controlled := FALSE;
      ELSE
         is_locator_controlled := TRUE;
      END IF;
    END IF;

   IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
      IF (is_locator_controlled = TRUE) THEN

         inv_mwb_tree1.add_locs(
                            x_node_value
                          , x_node_tbl
                          , x_tbl_index
                          );
      END IF;

      -- If the given subinventory is not locator controlled then add items
      -- directly under subinventory, else if the locator is determined at item level
      -- add both items and subinventories.

      IF is_locator_controlled = FALSE
          OR inv_mwb_globals.g_locator_control_code = 5
          OR loc_type = 5
      THEN
        IF  inv_mwb_globals.g_lpn_from IS NULL
        AND inv_mwb_globals.g_lpn_to IS NULL THEN

         inv_mwb_globals.g_containerized := 1;
         inv_mwb_globals.g_locator_controlled := 1;

         inv_mwb_tree1.add_items(
            x_node_value
            , x_node_tbl
            , x_tbl_index
            );
        END IF;
      END IF;

    ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

--      IF(inv_mwb_globals.g_chk_onhand = 1) THEN
      IF(inv_mwb_globals.g_tree_mat_loc_id = 1) THEN
         IF inv_mwb_globals.g_serial_from IS NOT NULL  ---serials entered in qf
         OR inv_mwb_globals.g_serial_to IS NOT NULL
         OR inv_mwb_globals.g_status_id IS NOT NULL
	 OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
            make_common_query_onhand('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'msn.current_subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'msn.current_locator_id';

            inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');

            inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.current_subinventory_code = :onh_tree_subinventory_code', 'ONHAND');

            inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_query_onhand('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'moqd.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'moqd.locator_id';

            inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');

            inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');

            inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;

      END IF;

      IF (inv_mwb_globals.g_tree_mat_loc_id = 2) THEN -- Receiving node chosen
         IF inv_mwb_globals.g_serial_from IS NOT NULL OR
            inv_mwb_globals.g_serial_to IS NOT NULL THEN
            make_common_query_receiving('MSN_QUERY');
            inv_mwb_query_manager.add_qf_where_receiving('MSN');
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'rs.to_locator_id';

            inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
       	    inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');

            inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
         ELSE
            make_common_query_receiving('RECEIVING');
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'rs.to_locator_id';

            inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');

            inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');

            inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);

            inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
         END IF;
      END IF;
      inv_mwb_query_manager.execute_query;
  END IF; -- node selected

  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END sub_node_event;


  PROCEDURE loc_node_event(
                          x_node_value          IN OUT NOCOPY NUMBER
                        , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
                        , x_tbl_index           IN OUT NOCOPY NUMBER
                        )
   IS
      i                    NUMBER                                                := 1;
      j                    NUMBER                                                := 1;
      str_query          varchar2(4000);
      l_procedure_name   VARCHAR2(30);

   BEGIN
      l_procedure_name := 'LOC_NODE_EVENT';
   IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
      inv_mwb_tree1.add_lpns(
                            x_node_value
                          , x_node_tbl
                          , x_tbl_index
                          );

      IF  inv_mwb_globals.g_lpn_from IS NULL
      AND inv_mwb_globals.g_lpn_to IS NULL THEN

         inv_mwb_globals.g_locator_controlled := 2;
         inv_mwb_globals.g_containerized := 1;

         inv_mwb_tree1.add_items(
                               x_node_value
                             , x_node_tbl
                             , x_tbl_index
                             );
      END IF;

   ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

      IF (inv_mwb_globals.g_tree_mat_loc_id = 1) THEN -- Onhand node chosen
            IF inv_mwb_globals.g_serial_from IS NOT NULL  ---serials entered in qf
            OR inv_mwb_globals.g_serial_to IS NOT NULL
            OR inv_mwb_globals.g_status_id IS NOT NULL
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_query_onhand('MSN_QUERY');

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_locator_id = :onh_tree_loc_id', 'ONHAND');

               inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
               inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
               inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);

               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('moqd.locator_id = :onh_tree_loc_id', 'ONHAND');

               inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
               inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
               inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';
		  --Bug 8840288 Added LotNumber
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                  'moqd.lot_number';
	       inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
	       --Bug 8840288 Added LotNumber
	       inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');

               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
            END IF; -- Serial Entered
         END IF; -- ONHAND


         IF (inv_mwb_globals.g_tree_mat_loc_id = 2) THEN -- Receiving node chosen
         IF inv_mwb_globals.g_serial_from IS NOT NULL OR
            inv_mwb_globals.g_serial_to IS NOT NULL THEN
            make_common_query_receiving('MSN_QUERY');
            inv_mwb_query_manager.add_qf_where_receiving('MSN');
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'rs.to_locator_id';

            inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
       	    inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.to_locator_id = :rcv_tree_locator', 'RECEIVING');

            inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
            inv_mwb_query_manager.add_bind_variable('rcv_tree_locator', inv_mwb_globals.g_tree_loc_id);
         ELSE
            make_common_query_receiving('RECEIVING');
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'rs.to_locator_id';

            inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');

            inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.to_locator_id = :rcv_tree_locator', 'RECEIVING');

            inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
            inv_mwb_query_manager.add_bind_variable('rcv_tree_locator', inv_mwb_globals.g_tree_loc_id);

            inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
          END IF;
        END IF;
        inv_mwb_query_manager.execute_query;
      END IF; -- node selected
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END loc_node_event;

   PROCEDURE lpn_node_event(
                          x_node_value          IN OUT NOCOPY NUMBER
                        , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
                        , x_tbl_index           IN OUT NOCOPY NUMBER
                        )
   IS
      str_query varchar2(4000);
      l_procedure_name VARCHAR2(30);
      l_req_header_id  NUMBER;
      l_lpn_id         NUMBER;

       l_rev_control    NUMBER;
       l_lot_control    NUMBER;
       l_serial_control NUMBER;
       l_return_val     BOOLEAN := FALSE; -- bug 8920503

   BEGIN
      l_procedure_name := 'LPN_NODE_EVENT';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Gonig to add LPN');

         IF inv_mwb_globals.g_tree_loc_id IS NULL THEN
            inv_mwb_globals.g_locator_controlled := 1;
         END IF;
         inv_mwb_globals.g_containerized := 2;

         inv_mwb_tree1.add_lpns(
                             x_node_value
                           , x_node_tbl
                           , x_tbl_index
                           );
         inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Gonig to add ITEM');
         inv_mwb_tree1.add_items(
                             x_node_value
                           , x_node_tbl
                           , x_tbl_index
                           );

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

       --START Bug7462485
 	IF (inv_mwb_globals.g_inventory_item_id IS NOT NULL)  THEN  --bug 8920503

         l_return_val := inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_inventory_item_id);
         IF l_return_val THEN

          l_lot_control := inv_cache.item_rec.lot_control_code;
          l_rev_control := inv_cache.item_rec.revision_qty_control_code;
          l_serial_control:= inv_cache.item_rec.serial_number_control_code;

         END IF;
        END IF;

 	--End Bug7462485


         IF (inv_mwb_globals.g_tree_mat_loc_id = 1) THEN -- Onhand node chosen

            inv_mwb_query_manager.make_nested_lpn_onhand_query;

          -- Start Bug7462485 Added code to take care of all the flavors of items.

            IF (inv_mwb_globals.g_serial_from IS NOT NULL
 	             OR inv_mwb_globals.g_serial_to IS  NOT NULL)
 	             OR (NVL(l_rev_control, 1) = 1 AND NVL(l_lot_control, 1) = 1
 	             AND l_serial_control IN ( 2,5 ))
 	             OR inv_mwb_globals.g_status_id IS NOT NULL
 	             OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';


               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id', 'ONHAND');

                   inv_mwb_query_manager.add_where_clause(
                                                   'msn.lpn_id = :onh_tree_plpn_id' ,
                                                   'ONHAND'
                                                   );

               IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.current_locator_id = :onh_tree_loc_id' ,
                                                   'ONHAND'
                                                   );
               ELSE
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.current_locator_id IS NULL' ,
                                                   'ONHAND'
                                                   );
               END IF;

               IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.current_subinventory_code = :onh_tree_sub_code' ,
                                                   'ONHAND'
                                                   );
               END IF;
       ELSE

                inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');

	       inv_mwb_query_manager.add_where_clause(
                                                   'moqd.lpn_id = :onh_tree_plpn_id' ,
                                                   'ONHAND'
                                                   );

               IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.locator_id = :onh_tree_loc_id' ,
                                                   'ONHAND'
                                                   );
               ELSE
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.locator_id IS NULL' ,
                                                   'ONHAND'
                                                   );
               END IF;

               IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.subinventory_code = :onh_tree_sub_code' ,
                                                   'ONHAND'
                                                   );
               END IF;
            END IF;

	    IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_plpn_id',
                                                inv_mwb_globals.g_tree_parent_lpn_id
                                                );
            END IF;

            IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
               inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_loc_id',
                                                inv_mwb_globals.g_tree_loc_id
                                                );
            END IF;

            IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
               inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_sub_code',
                                                inv_mwb_globals.g_tree_subinventory_code
                                                );
            END IF;

              IF NVL(l_rev_control, 1) = 1 AND NVL(l_lot_control, 1) = 1
            AND l_serial_control IN ( 2,5 ) THEN

               make_common_query_onhand('MSN_QUERY');
               IF (inv_mwb_globals.g_inventory_item_id IS NOT NULL)  THEN
	       inv_mwb_query_manager.add_where_clause(
                                             'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                                             'ONHAND'
                                             );
               END IF;
               inv_mwb_query_manager.add_where_clause(
                                             'msn.current_organization_id = :onh_tree_organization_id' ,
                                             'ONHAND'
                                             );
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

            ELSE  -- only serial controlled
               IF inv_mwb_globals.g_serial_from IS NOT NULL OR
                  inv_mwb_globals.g_serial_to IS NOT NULL
                              OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN

                  make_common_query_onhand('MSN_QUERY');
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
                  IF (inv_mwb_globals.g_inventory_item_id IS NOT NULL)  THEN
		  inv_mwb_query_manager.add_where_clause(
                                                   'msn.inventory_item_id = :onh_tree_inventory_item_id' ,
                                                   'ONHAND'
                                                   );
                  END IF;
		  inv_mwb_query_manager.add_where_clause(
                                                   'msn.current_organization_id = :onh_tree_organization_id' ,
                                                   'ONHAND'
                                                   );
                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
               ELSE -- serial entered in qf
                  make_common_query_onhand('MOQD');

		  IF (inv_mwb_globals.g_inventory_item_id IS NOT NULL)  THEN
		  inv_mwb_query_manager.add_where_clause(
                                       'moqd.inventory_item_id = :onh_tree_inventory_item_id' ,
                                       'ONHAND'
                                       );
                  END IF;
		  inv_mwb_query_manager.add_where_clause(
                                       'moqd.organization_id = :onh_tree_organization_id' ,
                                       'ONHAND'
                                       );

		     -- Bug 8601470
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                     'moqd.revision';
                     inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');


		     -- Bug 8601470
                     inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                        'moqd.lot_number';
                     inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');

                  inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
               END IF; -- serial in query find
            END IF;  -- only serial controlled
            inv_mwb_query_manager.add_bind_variable(
                                          'onh_tree_organization_id',
                                          inv_mwb_globals.g_tree_organization_id
                                          );
            IF (inv_mwb_globals.g_inventory_item_id IS NOT NULL)  THEN
	    inv_mwb_query_manager.add_bind_variable(
                                          'onh_tree_inventory_item_id',
                                          inv_mwb_globals.g_inventory_item_id
                                          );
            ENd IF;
	  END IF; --ONHAND

           -- End Bug7462485

         IF (inv_mwb_globals.g_tree_mat_loc_id = 3) THEN -- Inbound node chosen
             inv_mwb_query_manager.make_nested_lpn_inbound_query;
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
                'ms.intransit_owning_org_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.EXPECTED_RECEIPT_DATE).column_value :=
                'ms.expected_delivery_date';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.FROM_ORG_ID).column_value :=
                'ms.from_organization_id';
             inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.expected_delivery_date', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.from_organization_id', 'INBOUND');

      CASE inv_mwb_globals.g_tree_doc_type_id
         WHEN 1 THEN
            null;
         WHEN 2 THEN
             make_common_query_inbound('INBOUND');
             inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
             inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'For item under Requisition');
   	       inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Under Req item selecetd');
	          inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REQ_HEADER_ID).column_value :=
    		      'ms.req_header_id';
    	       inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
    		      'ms.req_line_id';
    	       inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
    		      'rsl.asn_lpn_id';

             inv_mwb_query_manager.add_group_clause('ms.req_header_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.req_line_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.supply_type_code IN (''REQ'',''SHIPMENT'')', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.req_header_id = :req_header_id', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
             inv_mwb_query_manager.add_bind_variable('req_header_id', inv_mwb_globals.g_tree_doc_header_id);
             inv_mwb_query_manager.add_bind_variable('item_id', inv_mwb_globals.g_tree_item_id);
             inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
          WHEN 3 THEN
             inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Making query for internal intransit');
             make_common_query_inbound('INBOUND');
             inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
		         'ms.shipment_header_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
		         'ms.shipment_line_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
		         'rsl.asn_lpn_id';

             inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');

             inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NULL', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('rsh.shipment_num = :shipment_num', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :asn_lpn_id', 'INBOUND');
             inv_mwb_query_manager.add_bind_variable('asn_lpn_id',inv_mwb_globals.g_tree_parent_lpn_id);

             inv_mwb_query_manager.add_bind_variable('shipment_num', inv_mwb_globals.g_tree_doc_num);

          WHEN 4 THEN
             make_common_query_inbound('INBOUND');
             inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
		         'ms.shipment_header_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
		         'ms.shipment_line_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
		         'rsl.asn_lpn_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_ID).column_value :=
		         'rsh.vendor_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_SITE_ID).column_value :=
		         'rsh.vendor_site_id';

   	       inv_mwb_query_manager.add_group_clause('rsh.vendor_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('rsh.vendor_site_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');

             inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NOT NULL', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('rsh.RECEIPT_SOURCE_CODE = ''VENDOR''', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('rsh.shipment_num = :shipment_num', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :asn_lpn_id', 'INBOUND');
             inv_mwb_query_manager.add_bind_variable('shipment_num', inv_mwb_globals.g_tree_doc_num);
             inv_mwb_query_manager.add_bind_variable('asn_lpn_id',inv_mwb_globals.g_tree_parent_lpn_id);
         END CASE;
      END IF;


      IF (inv_mwb_globals.g_tree_mat_loc_id = 2) THEN -- Receiving node chosen
         inv_mwb_query_manager.make_nested_lpn_rcv_query;
         IF inv_mwb_globals.g_serial_from IS NOT NULL OR
            inv_mwb_globals.g_serial_to IS NOT NULL THEN
            make_common_query_receiving('MSN_QUERY');
            inv_mwb_query_manager.add_qf_where_receiving('MSN');
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'rs.to_locator_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'rs.lpn_id';

            inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.lpn_id', 'RECEIVING');

   	      inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_lpn_id', 'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('rcv_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

            IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
            END IF;

            IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('rs.to_locator_id = :rcv_tree_locator', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_locator', inv_mwb_globals.g_tree_loc_id);
            END IF;

         ELSE
            make_common_query_receiving('RCV_TREE_LPN');
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'wlpn.subinventory_code';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'wlpn.locator_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'wlpn.lpn_id';

            inv_mwb_query_manager.add_group_clause('wlpn.subinventory_code', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('wlpn.locator_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('wlpn.lpn_id', 'RECEIVING');

            IF inv_mwb_globals.g_tree_organization_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('wlpn.organization_id = :rcv_tree_organization_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            END IF;

            IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('wlpn.subinventory_code = :rcv_tree_subinventory_code', 'RECEIVING');
              inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
            END IF;

            IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('wlpn.locator_id = :rcv_tree_locator_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_locator_id', inv_mwb_globals.g_tree_loc_id);
            END IF;

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('wlpn.lpn_id = :rcv_tree_lpn_id', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            END IF;
            inv_mwb_query_manager.add_qf_where_lpn_node('RECEIVING');
         END IF;
      END IF;
      inv_mwb_query_manager.execute_query;
   END IF;
   inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, ' Leaving lpn_node_event');

   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END lpn_node_event;


   PROCEDURE item_node_event(
                         x_node_value IN OUT NOCOPY NUMBER
                        ,x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
                        ,x_tbl_index  IN OUT NOCOPY NUMBER
   ) IS

      from_receiving   NUMBER;
      loc_control      NUMBER;
      rev_control      NUMBER;
      lot_control      NUMBER;
      containerized    NUMBER;
      prepacked        NUMBER;
      serial_control   NUMBER;
      select_lot       NUMBER;
      select_serial    NUMBER;
      select_grade     NUMBER;
      str_query        VARCHAR2(4000);
      l_procedure_name VARCHAR2(30);
      l_po_header_id   NUMBER;
      l_req_header_id  NUMBER;
      l_shipment_header_id NUMBER;
      l_rev_control    NUMBER;
      l_lot_control    NUMBER;
      l_serial_control NUMBER;
      l_lot_controlled       NUMBER := 0; -- Onhand Material Status Support
      l_serial_controlled    NUMBER := 0; -- Onhand Material Status Support
      l_default_status_id    NUMBER; -- Onhand Material Status Support

   BEGIN
      l_procedure_name := 'ITEM_NODE_EVENT';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

         IF inv_mwb_globals.g_tree_loc_id IS NULL THEN
            loc_control := 1;
         ELSE
            loc_control := 2;
         END IF;

         IF inv_mwb_globals.g_tree_parent_lpn_id IS NULL THEN
            containerized := 1;
         ELSE
            containerized := 2;
         END IF;

         IF containerized =1  THEN
            prepacked := 1;
         ELSE
            IF inv_mwb_globals.g_sub_type = 2 THEN
               prepacked := 1;
            ELSE
               prepacked := NULL;
            END IF;
         END IF;

         IF NVL(inv_mwb_globals.g_tree_doc_type_id,-99) <> 1 THEN

            inv_mwb_globals.g_locator_controlled := loc_control;
            inv_mwb_globals.g_containerized := containerized;

            inv_mwb_tree1.add_revs(
                                x_node_value
                              , x_node_tbl
                              , x_tbl_index
                              );

            IF x_tbl_index = 1 THEN

               inv_mwb_globals.g_revision_controlled :=  1;
               inv_mwb_globals.g_locator_controlled := loc_control;
               inv_mwb_globals.g_containerized := containerized;

               inv_mwb_tree1.add_lots(
                                   x_node_value
                                 , x_node_tbl
                                 , x_tbl_index
                                 );

               IF x_tbl_index = 1 THEN

                  inv_mwb_globals.g_revision_controlled :=  1;
                  inv_mwb_globals.g_locator_controlled := loc_control;
                  inv_mwb_globals.g_containerized := containerized;
                  inv_mwb_globals.g_lot_controlled := 1;

                  inv_mwb_tree1.add_serials(
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
           INTO l_rev_control,
                l_lot_control,
                l_serial_control
           FROM mtl_system_items
          WHERE inventory_item_id = inv_mwb_globals.g_tree_item_id
            AND organization_id = inv_mwb_globals.g_tree_organization_id;

         IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN

            IF (inv_mwb_globals.g_serial_from IS NOT NULL
            OR inv_mwb_globals.g_serial_to IS  NOT NULL)
            OR (NVL(l_rev_control, 1) = 1 AND NVL(l_lot_control, 1) = 1
            AND l_serial_control IN ( 2,5 ))
            OR inv_mwb_globals.g_status_id IS NOT NULL
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'msn.current_subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'msn.current_locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'msn.lpn_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'msn.cost_group_id';

               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.cost_group_id', 'ONHAND');

               IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.lpn_id = :onh_tree_lpn_id' ,
                                                   'ONHAND'
                                                   );
               ELSE
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.lpn_id IS NULL' ,
                                                   'ONHAND'
                                                   );
               END IF;

               IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.current_locator_id = :onh_tree_loc_id' ,
                                                   'ONHAND'
                                                   );
               ELSE
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.current_locator_id IS NULL' ,
                                                   'ONHAND'
                                                   );
               END IF;

               IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'msn.current_subinventory_code = :onh_tree_sub_code' ,
                                                   'ONHAND'
                                                   );
               END IF;
            ELSE
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                  'moqd.cost_group_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                  'moqd.locator_id';
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'moqd.lpn_id';

               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');

               -- Onhand Material Status Support
               -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.
               if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
                  l_default_status_id :=  inv_cache.org_rec.default_status_id;
               end if;

               if inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) then
                 if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
                    l_serial_controlled := 1; -- Item is serial controlled
                 end if;

                 if (inv_cache.item_rec.lot_control_code <> 1) then
                    l_lot_controlled := 1; -- Item is lot controlled
                 end if;
               end if;

               if (l_default_status_id is not null and l_serial_controlled = 0 and l_lot_controlled = 0) then
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                  'moqd.status_id';
                  inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
               end if;
               -- End Onhand Material Status Support

               IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.lpn_id = :onh_tree_lpn_id' ,
                                                   'ONHAND'
                                                   );
               ELSE
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.lpn_id IS NULL' ,
                                                   'ONHAND'
                                                   );
               END IF;

               IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.locator_id = :onh_tree_loc_id' ,
                                                   'ONHAND'
                                                   );
               ELSE
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.locator_id IS NULL' ,
                                                   'ONHAND'
                                                   );
               END IF;

               IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
                  inv_mwb_query_manager.add_where_clause(
                                                   'moqd.subinventory_code = :onh_tree_sub_code' ,
                                                   'ONHAND'
                                                   );
               END IF;
            END IF;

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_lpn_id',
                                                inv_mwb_globals.g_tree_parent_lpn_id
                                                );
            END IF;

            IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
               inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_loc_id',
                                                inv_mwb_globals.g_tree_loc_id
                                                );
            END IF;

            IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
               inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_sub_code',
                                                inv_mwb_globals.g_tree_subinventory_code
                                                );
            END IF;

            IF NVL(l_rev_control, 1) = 1 AND NVL(l_lot_control, 1) = 1
            AND l_serial_control IN ( 2,5 ) THEN

               make_common_query_onhand('MSN');
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
                  make_common_query_onhand('MSN_QUERY');
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
                  make_common_query_onhand('MOQD');
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

         ELSIF (inv_mwb_globals.g_tree_mat_loc_id = 3) THEN -- INBOUND NODE CHOSEN

            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.add_qf_where_inbound('INBOUND');

            IF inv_mwb_globals.g_tree_doc_type_id IN (3,4) THEN
               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REVISION).column_value :=
                     'ms.item_revision';
                  inv_mwb_query_manager.add_group_clause('ms.item_revision', 'INBOUND');
               ELSE
                  IF l_lot_control = 2 THEN
                     inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
                        'rls.lot_num';
                     -- for bug 8420783
                     -- for bug 8414727
                     -- here only for serial control code 2, because for serial control code 2, the query sql will join the rcv_serials_supply
                     -- so need to add lot number condition to where_clause.
                     IF (inv_mwb_globals.g_serial_from IS NOT NULl or inv_mwb_globals.g_serial_to is NOT NULL)
                      or (l_serial_control = 2) THEN
                         inv_mwb_query_manager.add_where_clause('rss.lot_num = rls.lot_num', 'INBOUND');
                         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
                         'count(1)';
                     ELSE
                         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
                         'sum(rls.quantity)';
                     END IF ;
                     -- end of bug 8414727
                     -- end of bug 8420783
                     inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
                  ELSIF l_serial_control = 2 THEN
                     inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SERIAL).column_value :=
                        'rss.serial_num';
                     inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value := 1;
                     inv_mwb_query_manager.add_group_clause('rss.serial_num', 'INBOUND');
                  END IF;
               END IF;
            END IF;

            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
               'ms.intransit_owning_org_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.EXPECTED_RECEIPT_DATE).column_value :=
               'ms.expected_delivery_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.FROM_ORG_ID).column_value :=
               'ms.from_organization_id';

            inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.expected_delivery_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.from_organization_id', 'INBOUND');


            CASE inv_mwb_globals.g_tree_doc_type_id
               WHEN 1 THEN
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_NUMBER).column_value :=
                  inv_mwb_globals.g_tree_node_value;
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_HEADER_ID).column_value :=
                  'ms.po_header_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
                  'ms.po_line_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REVISION).column_value :=
                  'ms.item_revision';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_RELEASE_ID).column_value :=
                  'ms.po_release_id';

                  inv_mwb_query_manager.add_group_clause('ms.po_release_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.po_header_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.po_line_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.item_revision', 'INBOUND');

                  inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''PO''', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.po_header_id = :po_header_id', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
                  inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                  inv_mwb_query_manager.add_bind_variable('po_header_id', inv_mwb_globals.g_tree_doc_header_id);
                  inv_mwb_query_manager.add_bind_variable('item_id', inv_mwb_globals.g_tree_item_id);
--                  inv_mwb_query_manager.execute_query;

               WHEN 2 THEN

                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REQ_HEADER_ID).column_value :=
                     'ms.req_header_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
                     'ms.req_line_id';

                  inv_mwb_query_manager.add_group_clause('ms.req_header_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.req_line_id', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.supply_type_code IN (''REQ'',''SHIPMENT'')', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.req_header_id = :req_header_id', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
                  inv_mwb_query_manager.add_bind_variable('req_header_id', inv_mwb_globals.g_tree_doc_header_id);
                  inv_mwb_query_manager.add_bind_variable('item_id', inv_mwb_globals.g_tree_item_id);
                  inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);

               WHEN 3 THEN

                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
                  'ms.shipment_header_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
                  'ms.shipment_line_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
                  'rsh.shipped_date';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
                  'ms.intransit_owning_org_id';

                  inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('rsh.shipped_date', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NULL', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('rsh.shipment_num = :shipment_num', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
                  inv_mwb_query_manager.add_bind_variable('shipment_num', inv_mwb_globals.g_tree_doc_num);
                  inv_mwb_query_manager.add_bind_variable('item_id',inv_mwb_globals.g_tree_item_id);

                  IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                     inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
                        'rsl.asn_lpn_id';
                     inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :inb_tree_plpn_id', 'INBOUND');
                     inv_mwb_query_manager.add_bind_variable('inb_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
                     inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
                  ELSE
                     inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id IS NULL', 'INBOUND');
                  END IF;

               WHEN 4 THEN

                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
                  'ms.shipment_header_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
                  'ms.shipment_line_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_ID).column_value :=
                  'rsh.vendor_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_SITE_ID).column_value :=
                  'rsh.vendor_site_id';
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
                  'rsh.shipped_date';

                  inv_mwb_query_manager.add_group_clause('rsh.vendor_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('rsh.vendor_site_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
                  inv_mwb_query_manager.add_group_clause('rsh.shipped_date', 'INBOUND');

                  inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NOT NULL', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('rsh.RECEIPT_SOURCE_CODE = ''VENDOR''', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('rsh.shipment_num = :shipment_num', 'INBOUND');
                  inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
                  inv_mwb_query_manager.add_bind_variable('shipment_num', inv_mwb_globals.g_tree_doc_num);
                  inv_mwb_query_manager.add_bind_variable('item_id',inv_mwb_globals.g_tree_item_id);

                  IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                     inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
                        'rsl.asn_lpn_id';
                     inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :inb_tree_plpn_id', 'INBOUND');
                     inv_mwb_query_manager.add_bind_variable('inb_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
                     inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
                  ELSE
                     inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id IS NULL', 'INBOUND');
                  END IF;

            END CASE;


         ELSIF (inv_mwb_globals.g_tree_mat_loc_id = 2) THEN -- Receiving node chosen

            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'rs.to_locator_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'rs.lpn_id';

            inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.lpn_id', 'RECEIVING');

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_tree_plpn_id' ,'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            ELSE
               inv_mwb_query_manager.add_where_clause('rs.lpn_id IS NULL', 'RECEIVING');
            END IF;

            IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('rs.to_locator_id = :rcv_tree_loc_id' ,'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
            ELSE
               inv_mwb_query_manager.add_where_clause('rs.to_locator_id IS NULL' ,'RECEIVING');
            END IF;

            IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');
               inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
            ELSE
               inv_mwb_query_manager.add_where_clause('rs.to_subinventory IS NULL', 'RECEIVING');
            END IF;

            inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.item_id = :rcv_tree_item_id', 'RECEIVING');

            inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('rcv_tree_item_id', inv_mwb_globals.g_tree_item_id);


            IF (inv_mwb_globals.g_serial_from IS NOT NULL OR inv_mwb_globals.g_serial_to IS NOT NULL)
            OR l_serial_control IN ( 2,5 )  THEN
               inv_mwb_query_manager.add_qf_where_receiving('MSN');
               make_common_query_receiving('MSN');
               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.REVISION).column_value :=
                  'rs.item_revision';
                  inv_mwb_query_manager.add_group_clause('rs.item_revision', 'RECEIVING');
                  ELSIF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
                  'rss.lot_num';
                  inv_mwb_query_manager.add_group_clause('rss.lot_num', 'RECEIVING');
               ELSE
                  inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Adding Serial');
                  inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SERIAL).column_value :=
                  'rss.serial_num';
                  inv_mwb_query_manager.add_group_clause('rss.serial_num', 'RECEIVING');
               END IF;
            ELSIF l_serial_control NOT IN (2,5) THEN
               inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
               make_common_query_receiving('RECEIVING');
               IF l_rev_control = 2 THEN
                  inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.REVISION).column_value :=
                  'rs.item_revision';
                  inv_mwb_query_manager.add_group_clause('rs.item_revision', 'RECEIVING');
               ELSIF l_lot_control = 2 THEN
                  inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
                  'rls.lot_num';
                  inv_mwb_query_manager.add_group_clause('rls.lot_num', 'RECEIVING');
               END IF;
            END IF;
         END IF;
         inv_mwb_query_manager.execute_query;
      END IF; -- node selected
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
   END item_node_event;


  PROCEDURE rev_node_event(
    x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   )
   IS
      loc_control            NUMBER;
      l_lot_control          NUMBER;
      l_serial_control       NUMBER;
      containerized          NUMBER;
      select_serial          NUMBER     := 0;
      select_grade           NUMBER     := 0;                -- NSRIVAST, INVCONV
      str_query              VARCHAR2(4000);
      l_procedure_name       VARCHAR2(30);
      l_po_header_id         NUMBER;
      l_req_header_id        NUMBER;
      l_lot_controlled       NUMBER := 0; -- Onhand Material Status Support
      l_serial_controlled    NUMBER := 0; -- Onhand Material Status Support
      l_default_status_id    NUMBER; -- Onhand Material Status Support

   BEGIN

/*Bug3457132-Introduced a new parameter CHECK which is set to 'Y' when
  there is an item-node-event and inv_mwb_globals.g_tree_rev-node-event*/

--  copy('Y','PARAMETER.CHECK');
    l_procedure_name := 'REV_NODE_EVENT';
    inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
    IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN

      IF inv_mwb_globals.g_tree_loc_id IS NULL THEN
        loc_control := 1;
      ELSE
        loc_control := 2;
      END IF;

      IF inv_mwb_globals.g_tree_parent_lpn_id IS NULL THEN
        containerized := 1;
      ELSE
        containerized := 2;
      END IF;

      IF containerized =1  THEN
        inv_mwb_globals.g_prepacked := 1;
      ELSE
        IF inv_mwb_globals.g_sub_type = 2 THEN
          inv_mwb_globals.g_prepacked := 1;
        ELSE
          inv_mwb_globals.g_prepacked := NULL;
        END IF;
      END IF;

      inv_mwb_globals.g_locator_controlled := loc_control;
      inv_mwb_globals.g_containerized := containerized;

      inv_mwb_tree1.add_lots(
                  x_node_value
                 , x_node_tbl
                 , x_tbl_index
                 );

      IF x_tbl_index = 1 THEN

        inv_mwb_globals.g_locator_controlled := loc_control;
        inv_mwb_globals.g_containerized := containerized;
        inv_mwb_globals.g_lot_controlled := 1;

        inv_mwb_tree1.add_serials(
                     x_node_value
                    , x_node_tbl
                    , x_tbl_index
                    );
      END IF;

    ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
      SELECT lot_control_code
           , serial_number_control_code
      INTO   l_lot_control
           , l_serial_control
      FROM   mtl_system_items
      WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
      AND    organization_id = inv_mwb_globals.g_tree_organization_id;

      IF inv_mwb_globals.g_tree_loc_id IS NULL THEN
        loc_control := 1;
      ELSE
        loc_control := 2;
      END IF;

      IF (inv_mwb_globals.g_tree_mat_loc_id = 1) THEN -- Onhand node chosen
      --Serial Controlled
      IF (inv_mwb_globals.g_serial_from IS NOT NULL OR inv_mwb_globals.g_serial_to IS NOT NULL)
      OR l_serial_control IN ( 2,5 )
      OR inv_mwb_globals.g_status_id IS NOT NULL
      OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880

         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         make_common_query_onhand('MSN_QUERY');

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
            'msn.current_subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
            'msn.current_locator_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
            'msn.lpn_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
            'msn.revision';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
            'msn.cost_group_id';

         inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.lpn_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.revision', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.cost_group_id', 'ONHAND');

         IF l_lot_control = 2 THEN
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
               'msn.lot_number';
            inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');
         ELSE
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
               'msn.serial_number';
            inv_mwb_query_manager.add_group_clause('msn.serial_number', 'ONHAND');
         END IF;

         inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id' ,'ONHAND');
         inv_mwb_query_manager.add_where_clause('msn.current_subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
         inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_tree_item_id', 'ONHAND');

         inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
         inv_mwb_query_manager.add_bind_variable('onh_tree_item_id', inv_mwb_globals.g_tree_item_id);

         IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_tree_plpn_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
         ELSE
            inv_mwb_query_manager.add_where_clause('msn.lpn_id IS NULL', 'ONHAND');
         END IF;

         IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('msn.current_locator_id = :onh_tree_loc_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
         ELSE
            inv_mwb_query_manager.add_where_clause('msn.current_locator_id IS NULL' ,'ONHAND');
         END IF;

         inv_mwb_query_manager.add_where_clause('msn.revision = :onh_tree_revision' ,'ONHAND');
         inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);

      ELSIF l_serial_control NOT IN (2,5) THEN

         make_common_query_onhand('MOQD');
         inv_mwb_query_manager.add_qf_where_onhand('ONHAND');

         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
         'moqd.subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
         'moqd.locator_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
         'moqd.lot_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
         'moqd.cost_group_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
         'moqd.lpn_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
         'moqd.revision';

         inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');

         -- Onhand Material Status Support
         -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.
         if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
               l_default_status_id :=  inv_cache.org_rec.default_status_id;
         end if;

         if inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) then
            if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
                 l_serial_controlled := 1; -- Item is serial controlled
            end if;

            if (inv_cache.item_rec.lot_control_code <> 1) then
                 l_lot_controlled := 1; -- Item is lot controlled
            end if;
         end if;

         if (l_default_status_id is not null and l_serial_controlled = 0 and l_lot_controlled = 0) then
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
            'moqd.status_id';
            inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
         end if;
         -- End Onhand Material Status Support

         IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_tree_plpn_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
         ELSE
            inv_mwb_query_manager.add_where_clause('moqd.lpn_id IS NULL', 'ONHAND');
         END IF;

         IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('moqd.locator_id = :onh_tree_loc_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
         ELSE
            inv_mwb_query_manager.add_where_clause('moqd.locator_id IS NULL', 'ONHAND');
         END IF;

         inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
         inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
         inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_item_id' ,'ONHAND');
         inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');

         inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
         inv_mwb_query_manager.add_bind_variable('onh_tree_item_id', inv_mwb_globals.g_tree_item_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);

      END IF;
   END IF;



   IF inv_mwb_globals.g_tree_mat_loc_id = 3 THEN

      CASE inv_mwb_globals.g_tree_doc_type_id
         WHEN 1 THEN
            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_NUMBER).column_value :=
            inv_mwb_globals.g_tree_node_value;
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_HEADER_ID).column_value :=
               'ms.po_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.po_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REVISION).column_value :=
               'ms.item_revision';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_HEADER_ID).column_value :=
               'ms.po_release_id';
            inv_mwb_query_manager.add_group_clause('ms.po_release_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.po_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.po_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.item_revision', 'INBOUND');

            inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''PO''', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.po_header_id = :po_header_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.item_revision = :item_revision', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('po_header_id', inv_mwb_globals.g_tree_doc_header_id);
            inv_mwb_query_manager.add_bind_variable('item_id', inv_mwb_globals.g_tree_item_id);
            inv_mwb_query_manager.add_bind_variable('item_revision', inv_mwb_globals.g_tree_rev);
            inv_mwb_query_manager.execute_query;
            return;
         WHEN 2 THEN
             make_common_query_inbound('INBOUND');
             inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REQ_HEADER_ID).column_value :=
               'ms.req_header_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.req_line_id';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
               'rls.lot_num';
             inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT_EXPIRY_DATE).column_value :=
               'rls.expiration_date';

             inv_mwb_query_manager.add_group_clause('ms.req_header_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.req_line_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('rls.expiration_date', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.supply_type_code IN (''REQ'',''SHIPMENT'')', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.req_header_id = :req_header_id', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
             inv_mwb_query_manager.add_bind_variable('req_header_id', inv_mwb_globals.g_tree_doc_header_id);
             inv_mwb_query_manager.add_bind_variable('item_id', inv_mwb_globals.g_tree_item_id);

         WHEN 3 THEN

            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.add_qf_where_inbound('INBOUND');

            IF l_lot_control = 2 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
                  'rls.lot_num';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT_EXPIRY_DATE).column_value :=
                  'rls.expiration_date';
               inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
               inv_mwb_query_manager.add_group_clause('rls.expiration_date', 'INBOUND');
            ELSIF l_serial_control = 2 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SERIAL).column_value :=
                 'rss.serial_num';
               inv_mwb_query_manager.add_group_clause('rss.serial_num', 'INBOUND');
            END IF;

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rsl.asn_lpn_id';
               inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :asn_lpn_id', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('asn_lpn_id',inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
            END IF;

            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.shipment_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
               'rsh.shipped_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
               'ms.intransit_owning_org_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REVISION).column_value :=
               'ms.item_revision';

            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rsh.shipped_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.item_revision', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('rsh.shipment_header_id = :shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('shipment_header_id', inv_mwb_globals.g_tree_doc_header_id);
            inv_mwb_query_manager.add_bind_variable('item_id',inv_mwb_globals.g_tree_item_id);

         WHEN 4 THEN
            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.add_qf_where_inbound('INBOUND');

            IF l_lot_control = 2 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
                  'rls.lot_num';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT_EXPIRY_DATE).column_value :=
                  'rls.expiration_date';
               inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
               inv_mwb_query_manager.add_group_clause('rls.expiration_date', 'INBOUND');
            ELSIF l_serial_control = 2 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SERIAL).column_value :=
                 'rss.serial_num';
               inv_mwb_query_manager.add_group_clause('rss.serial_num', 'INBOUND');
            END IF;

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rsl.asn_lpn_id';
               inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :asn_lpn_id', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('asn_lpn_id',inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
            END IF;

            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.shipment_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
               'rsh.shipped_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
               'ms.intransit_owning_org_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REVISION).column_value :=
               'ms.item_revision';

            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rsh.shipped_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.item_revision', 'INBOUND');

            inv_mwb_query_manager.add_where_clause('rsh.shipment_header_id = :shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('shipment_header_id', inv_mwb_globals.g_tree_doc_header_id);
            inv_mwb_query_manager.add_bind_variable('item_id',inv_mwb_globals.g_tree_item_id);
         END CASE;
      END IF;

      IF (inv_mwb_globals.g_tree_mat_loc_id = 2) THEN -- Receiving node chosen
         inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
           'rs.to_subinventory';
         inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
           'rs.to_locator_id';
         inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
           'rs.lpn_id';
         inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.REVISION).column_value :=
           'rs.item_revision';

         inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
         inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
         inv_mwb_query_manager.add_group_clause('rs.lpn_id', 'RECEIVING');
         inv_mwb_query_manager.add_group_clause('rs.item_revision', 'RECEIVING');

         IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_tree_plpn_id' ,'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
         END IF;
         IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('rs.to_locator_id = :rcv_tree_loc_id' ,'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
         END IF;
         IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
         END IF;

         inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
         inv_mwb_query_manager.add_where_clause('rs.item_id = :rcv_tree_item_id', 'RECEIVING');
         inv_mwb_query_manager.add_where_clause('rs.item_revision = :rcv_tree_rev', 'RECEIVING');

         inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
         inv_mwb_query_manager.add_bind_variable('rcv_tree_item_id', inv_mwb_globals.g_tree_item_id);
         inv_mwb_query_manager.add_bind_variable('rcv_tree_rev', inv_mwb_globals.g_tree_rev);

         --Serial Controlled
         IF (inv_mwb_globals.g_serial_from IS NOT NULL OR inv_mwb_globals.g_serial_to IS NOT NULL)
         OR l_serial_control IN ( 2,5 )  THEN
            inv_mwb_query_manager.add_qf_where_receiving('MSN');
            make_common_query_receiving('MSN');
            IF l_lot_control = 2 THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
               'rss.lot_num';
               inv_mwb_query_manager.add_group_clause('rss.lot_num', 'RECEIVING');
            ELSE
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SERIAL).column_value :=
               'rss.serial_num';
               inv_mwb_query_manager.add_group_clause('rss.serial_num', 'RECEIVING');
            END IF;
         ELSIF l_serial_control NOT IN (2,5) THEN
            inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
            make_common_query_receiving('RECEIVING');
            IF l_lot_control = 2 THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
               'rls.lot_num';
               inv_mwb_query_manager.add_group_clause('rls.lot_num', 'RECEIVING');
            END IF;
         END IF;
      END IF;
   END IF;
      inv_mwb_query_manager.execute_query;
   END rev_node_event;

  PROCEDURE lot_node_event(
    x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
)
IS
    loc_control          NUMBER;
    rev_control          NUMBER;
    serial_control       NUMBER;
    containerized        NUMBER;
    select_serial        NUMBER    := 0;
    str_query            VARCHAR2(4000);
    l_procedure_name VARCHAR2(30);
    l_req_header_id  NUMBER;
    l_serial_controlled    NUMBER := 0; -- Onhand Material Status Support
    l_default_status_id    NUMBER; -- Onhand Material Status Support

  BEGIN
    l_procedure_name := 'LOT_NODE_EVENT';
    inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
    inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, inv_mwb_globals.g_tree_node_value);
    IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
      IF inv_mwb_globals.g_tree_loc_id IS NULL THEN
        loc_control := 1;
      ELSE
        loc_control := 2;
      END IF;

      IF inv_mwb_globals.g_tree_rev IS NULL THEN
        rev_control := 1;
      ELSE
        rev_control := 2;
      END IF;

      IF inv_mwb_globals.g_tree_parent_lpn_id IS NULL THEN
        containerized := 1;
      ELSE
        containerized := 2;
      END IF;

      IF containerized =1  THEN
        inv_mwb_globals.g_prepacked := 1;
      ELSE
        IF inv_mwb_globals.g_sub_type = 2 THEN
          inv_mwb_globals.g_prepacked := 1;
        ELSE
          inv_mwb_globals.g_prepacked := NULL;
        END IF;
      END IF;

      inv_mwb_globals.g_locator_controlled := loc_control;
      inv_mwb_globals.g_containerized := containerized;

      inv_mwb_tree1.add_serials(
                     x_node_value
                    , x_node_tbl
                    , x_tbl_index
                    );


    ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
      SELECT serial_number_control_code
      INTO   serial_control
      FROM   mtl_system_items
      WHERE  organization_id = inv_mwb_globals.g_tree_organization_id
      AND    inventory_item_id = inv_mwb_globals.g_tree_item_id;

      IF (inv_mwb_globals.g_tree_mat_loc_id = 1) THEN
         IF serial_control IN(2, 5)
         OR inv_mwb_globals.g_status_id IS NOT NULL THEN
            make_common_query_onhand('MSN_QUERY');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
               'msn.revision';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
               'msn.serial_number';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'msn.current_subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'msn.current_locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'msn.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'msn.cost_group_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
               'msn.lot_number';

            inv_mwb_query_manager.add_group_clause('msn.revision', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.serial_number', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.lpn_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.cost_group_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_tree_plpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            ELSE
               inv_mwb_query_manager.add_where_clause('msn.lpn_id IS NULL', 'ONHAND');
	    END IF;

	    IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('msn.revision = :onh_tree_revision' ,'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);
	    END IF;

	    IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('msn.current_locator_id = :onh_tree_loc_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
            ELSE
              inv_mwb_query_manager.add_where_clause('msn.current_locator_id IS NULL' ,'ONHAND');
	    END IF;

            inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.current_subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('msn.lot_number = :onh_tree_lot_num' ,'ONHAND');


            inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
            inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_lot_num', inv_mwb_globals.g_tree_node_value);

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
         ELSE
            make_common_query_onhand('MOQD');
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
               'moqd.revision';
--            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
--               'moqd.serial_number';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'moqd.subinventory_code';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
               'moqd.locator_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'moqd.lpn_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
               'moqd.cost_group_id';
            inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
               'moqd.lot_number';


            inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
--            inv_mwb_query_manager.add_group_clause('moqd.serial_number', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');
            inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');

            -- Onhand Material Status Support
            -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.

            inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'org id' ||inv_mwb_globals.g_tree_organization_id );

            if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
               l_default_status_id :=  inv_cache.org_rec.default_status_id;
            end if;

            inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'org status id' || l_default_status_id);

            if inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) then
              if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
                 l_serial_controlled := 1; -- Item is serial controlled
              end if;
            end if;

            inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'serial controlled' || l_serial_controlled);

            if (l_default_status_id is not null and l_serial_controlled = 0) then
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
               'moqd.status_id';
               inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
            end if;
            -- End Onhand Material Status Support

            IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);
            END IF;

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_tree_plpn_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
            ELSE
               inv_mwb_query_manager.add_where_clause('moqd.lpn_id IS NULL', 'ONHAND');
	    END IF;

            IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('moqd.locator_id = :onh_tree_loc_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
            ELSE
              inv_mwb_query_manager.add_where_clause('moqd.locator_id IS NULL', 'ONHAND');
	    END IF;

            inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
            inv_mwb_query_manager.add_where_clause('moqd.lot_number = :onh_tree_lot_num' ,'ONHAND');

            inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
            inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
            inv_mwb_query_manager.add_bind_variable('onh_tree_lot_num', inv_mwb_globals.g_tree_node_value);

            inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
         END IF;
      END IF;  --onhand

      IF (inv_mwb_globals.g_tree_mat_loc_id = 3) THEN


      CASE inv_mwb_globals.g_tree_doc_type_id
         WHEN 1 THEN
            null;
         WHEN 2 THEN
             inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
             inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'For item under Requisition');
   	       inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Under Req item selecetd');
	          inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REQ_HEADER_ID).column_value :=
    		      'ms.req_header_id';
    	       inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
    		      'ms.req_line_id';
     	       inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
    		      'rls.lot_num';
     	       inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT_EXPIRY_DATE).column_value :=
    		      'rls.expiration_date';

             inv_mwb_query_manager.add_group_clause('ms.req_header_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('ms.req_line_id', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
             inv_mwb_query_manager.add_group_clause('rls.expiration_date', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.supply_type_code IN (''REQ'',''SHIPMENT'')', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.req_header_id = :req_header_id', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
             inv_mwb_query_manager.add_where_clause('ms.item_id = :item_id', 'INBOUND');
             IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
                inv_mwb_query_manager.add_where_clause('rls.lot_num = :lot_num', 'INBOUND');
                inv_mwb_query_manager.add_bind_variable('lot_num',inv_mwb_globals.g_tree_lot_number);
             END IF;

             inv_mwb_query_manager.add_bind_variable('req_header_id', inv_mwb_globals.g_tree_doc_header_id);
             inv_mwb_query_manager.add_bind_variable('item_id', inv_mwb_globals.g_tree_item_id);
             inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
          WHEN 3 THEN

            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.add_from_clause('mtl_supply ms ','INBOUND');
            inv_mwb_query_manager.add_from_clause('rcv_shipment_lines rsl ','INBOUND');
            inv_mwb_query_manager.add_from_clause('rcv_lots_supply rls ','INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.shipment_line_id = rsl.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.shipment_line_id = rls.shipment_line_id', 'INBOUND');

             -- for bug 8420783
             -- for the bug 8414727
             IF (inv_mwb_globals.g_serial_from IS NOT NULl or inv_mwb_globals.g_serial_to is NOT NULL) THEN
                 inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
                 'count(1)';
             ELSE
                  inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
                  'sum(rls.quantity)';
             END IF ;

            IF serial_control = 2  or serial_control = 5 THEN

               inv_mwb_query_manager.add_from_clause('rcv_serials_supply rss ','INBOUND');
               inv_mwb_query_manager.add_where_clause('rss.shipment_line_id = rsl.shipment_line_id', 'INBOUND');

               inv_mwb_query_manager.add_where_clause('rss.lot_num = rls.lot_num', 'INBOUND');
               -- end of bug 8414727
               -- end of bug 8420783

               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SERIAL).column_value :=
                  'rss.serial_num';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value := 1;
               inv_mwb_query_manager.add_group_clause('rss.serial_num', 'INBOUND');

               IF NVL(inv_mwb_globals.g_serial_from, -1) = NVL(inv_mwb_globals.g_serial_to,-2) THEN
                  inv_mwb_query_manager.add_where_clause('rss.serial_num = :serial_num', 'INBOUND');
                  inv_mwb_query_manager.add_bind_variable('serial_num',inv_mwb_globals.g_serial_from);
               ELSE
                  IF inv_mwb_globals.g_serial_from IS NOT NULL THEN
                     inv_mwb_query_manager.add_where_clause('rss.serial_num >= :serial_from', 'INBOUND');
                     inv_mwb_query_manager.add_bind_variable('serial_from',inv_mwb_globals.g_serial_from);
                  END IF;
                  IF inv_mwb_globals.g_serial_to IS NOT NULL THEN
                     -- for bug 8420783
                     -- for bug 8414727
                     inv_mwb_query_manager.add_where_clause('rss.serial_num <= :serial_to', 'INBOUND');
                     -- end of bug 8414727
                     -- end of bug 8420783
                     inv_mwb_query_manager.add_bind_variable('serial_to',inv_mwb_globals.g_serial_to);
                  END IF;
               END IF;
            END IF;

            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REVISION).column_value :=
               'ms.item_revision';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.shipment_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
               'rls.lot_num';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT_EXPIRY_DATE).column_value :=
               'rls.expiration_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
               'ms.receipt_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
               'ms.intransit_owning_org_id';

            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rls.expiration_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.receipt_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.item_revision', 'INBOUND');

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rsl.asn_lpn_id';
               inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :asn_lpn_id', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('asn_lpn_id',inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
            END IF;

            IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('rls.lot_num = :lot_num', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('lot_num',inv_mwb_globals.g_tree_lot_number);
            END IF;

            IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('ms.item_revision = :inb_tree_rev', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('inb_tree_rev',inv_mwb_globals.g_tree_rev);
            END IF;

            inv_mwb_query_manager.add_where_clause('rsl.shipment_header_id = :shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('shipment_header_id', inv_mwb_globals.g_tree_doc_header_id);

         WHEN 4 THEN
            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.add_from_clause('mtl_supply ms ','INBOUND');
            inv_mwb_query_manager.add_from_clause('rcv_shipment_lines rsl ','INBOUND');
            inv_mwb_query_manager.add_from_clause('rcv_lots_supply rls ','INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.shipment_line_id = rsl.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.shipment_line_id = rls.shipment_line_id', 'INBOUND');

            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
               'sum(rls.quantity)';

            IF serial_control = 2
            OR inv_mwb_globals.g_serial_from IS NOT NULL
            OR inv_mwb_globals.g_serial_from IS NOT NULL THEN
               inv_mwb_query_manager.add_from_clause('rcv_serials_supply rss ','INBOUND');
               inv_mwb_query_manager.add_where_clause('rss.shipment_line_id = rsl.shipment_line_id', 'INBOUND');

               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SERIAL).column_value :=
                  'rss.serial_num';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value := 1;

               inv_mwb_query_manager.add_group_clause('rss.serial_num', 'INBOUND');
            END IF;

            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REVISION).column_value :=
               'ms.item_revision';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.shipment_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
               'rls.lot_num';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT_EXPIRY_DATE).column_value :=
               'rls.expiration_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
               'ms.receipt_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
               'ms.intransit_owning_org_id';

            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rls.expiration_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.receipt_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.item_revision', 'INBOUND');

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rsl.asn_lpn_id';
               inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :asn_lpn_id', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('asn_lpn_id',inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
            END IF;

            IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('rls.lot_num = :lot_num', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('lot_num',inv_mwb_globals.g_tree_lot_number);
            END IF;

            IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('ms.item_revision = :inb_tree_rev', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('inb_tree_rev',inv_mwb_globals.g_tree_rev);
            END IF;

            inv_mwb_query_manager.add_where_clause('rsl.shipment_header_id = :shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('shipment_header_id', inv_mwb_globals.g_tree_doc_header_id);

         END CASE;
   END IF;

    IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN

	inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
           'rs.to_subinventory';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
           'rs.to_locator_id';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
           'rs.lpn_id';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.REVISION).column_value :=
           'rs.item_revision';

	inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rs.lpn_id', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rs.item_revision', 'RECEIVING');


	IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
           inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_tree_plpn_id' ,'RECEIVING');
           inv_mwb_query_manager.add_bind_variable('rcv_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
        END IF;
        IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
           inv_mwb_query_manager.add_where_clause('rs.to_locator_id = :rcv_tree_loc_id' ,'RECEIVING');
           inv_mwb_query_manager.add_bind_variable('rcv_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
        END IF;
        IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
        END IF;
        IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('rs.item_revision = :rcv_tree_rev', 'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_rev', inv_mwb_globals.g_tree_rev);
        END IF;

	inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
        inv_mwb_query_manager.add_where_clause('rs.item_id = :rcv_tree_item_id', 'RECEIVING');

        inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
        inv_mwb_query_manager.add_bind_variable('rcv_tree_item_id', inv_mwb_globals.g_tree_item_id);

	--Serial Controlled
	IF (inv_mwb_globals.g_serial_from IS NOT NULL OR inv_mwb_globals.g_serial_to IS NOT NULL)
        OR serial_control IN ( 2,5 )  THEN
	   inv_mwb_query_manager.add_qf_where_receiving('MSN');
	   make_common_query_receiving('MSN');
           inv_mwb_query_manager.add_where_clause('rss.lot_num = :rcv_lot_num', 'RECEIVING');
           inv_mwb_query_manager.add_bind_variable('rcv_lot_num', inv_mwb_globals.g_tree_lot_number);

	   inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
              'rss.lot_num';
           inv_mwb_query_manager.add_group_clause('rss.lot_num', 'RECEIVING');

           inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SERIAL).column_value :=
              'rss.serial_num';
           inv_mwb_query_manager.add_group_clause('rss.serial_num', 'RECEIVING');
        ELSIF serial_control NOT IN (2,5) THEN
	   inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
	   make_common_query_receiving('RECEIVING');
           inv_mwb_query_manager.add_where_clause('rls.lot_num = :rcv_lot_num', 'RECEIVING');
           inv_mwb_query_manager.add_bind_variable('rcv_lot_num', inv_mwb_globals.g_tree_lot_number);
           inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
                 'rls.lot_num';
           inv_mwb_query_manager.add_group_clause('rls.lot_num', 'RECEIVING');
        END IF;
     END IF;
     inv_mwb_query_manager.execute_query; -- Bug 6060233
   END IF; -- node selected
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END lot_node_event;

  PROCEDURE serial_node_event(
    x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
)
IS
    serial               mtl_serial_numbers.serial_number%TYPE;
    loc_control          NUMBER;
    serial_control       NUMBER;
    from_receiving       NUMBER;
    str_query            VARCHAR2(4000);
    l_procedure_name     VARCHAR2(30);
    l_req_header_id      NUMBER;
  BEGIN
    l_procedure_name := 'SERIAL_NODE_EVENT';
    inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
    IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
      IF inv_mwb_globals.g_tree_mat_loc_id = 1 THEN
         make_common_query_onhand('MSN');
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
            'msn.revision';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
            'msn.current_locator_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
            'msn.lpn_id';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
            'msn.lot_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SERIAL).column_value :=
            'msn.serial_number';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
            'msn.current_subinventory_code';
         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
            'msn.cost_group_id';


   	   inv_mwb_query_manager.add_group_clause('msn.revision', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.current_locator_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.lpn_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.lot_number', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.serial_number', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.cost_group_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'ONHAND');
         inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');


     	   IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('msn.current_locator_id = :onh_tree_loc_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
         END IF;

         IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('msn.lpn_id = :onh_tree_plpn_id', 'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
         END IF;

         IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('msn.revision = :onh_tree_revision' ,'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);
         END IF;

         IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('msn.lot_number = :onh_tree_lot_number' ,'ONHAND');
            inv_mwb_query_manager.add_bind_variable('onh_tree_lot_number', inv_mwb_globals.g_tree_lot_number);
         END IF;

         inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id' ,'ONHAND');
         inv_mwb_query_manager.add_where_clause('msn.current_subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
         inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
         inv_mwb_query_manager.add_where_clause('msn.serial_number = :onh_tree_serial_number' ,'ONHAND');

         inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
         inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
         inv_mwb_query_manager.add_bind_variable('onh_tree_serial_number', inv_mwb_globals.g_tree_node_value);

         inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');

      END IF;

   IF (inv_mwb_globals.g_tree_mat_loc_id = 3) THEN

            make_common_query_inbound('INBOUND');
            inv_mwb_query_manager.add_from_clause('mtl_supply ms ','INBOUND');
            inv_mwb_query_manager.add_from_clause('rcv_shipment_lines rsl ','INBOUND');
            inv_mwb_query_manager.add_from_clause('rcv_serials_supply rss ','INBOUND');
            inv_mwb_query_manager.add_where_clause('rss.shipment_line_id = rsl.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.shipment_line_id = rsl.shipment_line_id', 'INBOUND');

            IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
               inv_mwb_query_manager.add_from_clause('rcv_lots_supply rls ','INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.shipment_line_id = rls.shipment_line_id', 'INBOUND');

               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT).column_value :=
                  'rls.lot_num';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LOT_EXPIRY_DATE).column_value :=
                  'rls.expiration_date';
               inv_mwb_query_manager.add_group_clause('rls.lot_num', 'INBOUND');
               inv_mwb_query_manager.add_group_clause('rls.expiration_date', 'INBOUND');

               inv_mwb_query_manager.add_where_clause('rls.lot_num = :lot_num', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('lot_num',inv_mwb_globals.g_tree_lot_number);
            END IF;


            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SERIAL).column_value :=
               'rss.serial_num';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.shipment_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
               'ms.receipt_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
               'ms.intransit_owning_org_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value := 1;
            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.receipt_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rss.serial_num', 'INBOUND');

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
                  'rsl.asn_lpn_id';
               inv_mwb_query_manager.add_where_clause('rsl.asn_lpn_id = :asn_lpn_id', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('asn_lpn_id',inv_mwb_globals.g_tree_parent_lpn_id);
               inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
            END IF;

            IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
               inv_mwb_query_manager.add_where_clause('ms.item_revision = :inb_tree_rev', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('inb_tree_rev',inv_mwb_globals.g_tree_rev);
            END IF;

            inv_mwb_query_manager.add_where_clause('rsl.shipment_header_id = :shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('shipment_header_id', inv_mwb_globals.g_tree_doc_header_id);

            inv_mwb_query_manager.add_where_clause('rss.serial_num = :serial' ,'INBOUND');
            inv_mwb_query_manager.add_bind_variable('serial', inv_mwb_globals.g_tree_serial_number);

   END IF;

    IF inv_mwb_globals.g_tree_mat_loc_id = 2 THEN

        inv_mwb_query_manager.add_qf_where_receiving('MSN');
	make_common_query_receiving('MSN');

	inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
           'rs.to_subinventory';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
           'rs.to_locator_id';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LPN_ID).column_value :=
           'rs.lpn_id';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.REVISION).column_value :=
           'rs.item_revision';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.LOT).column_value :=
           'rss.lot_num';
        inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SERIAL).column_value :=
           'rss.serial_num';

	inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rs.to_locator_id', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rs.lpn_id', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rs.item_revision', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rss.lot_num', 'RECEIVING');
        inv_mwb_query_manager.add_group_clause('rss.serial_num', 'RECEIVING');


	IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
           inv_mwb_query_manager.add_where_clause('rs.lpn_id = :rcv_tree_plpn_id' ,'RECEIVING');
           inv_mwb_query_manager.add_bind_variable('rcv_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
        END IF;
        IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
           inv_mwb_query_manager.add_where_clause('rs.to_locator_id = :rcv_tree_loc_id' ,'RECEIVING');
           inv_mwb_query_manager.add_bind_variable('rcv_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
        END IF;
        IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('rs.to_subinventory = :rcv_tree_subinventory_code', 'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
        END IF;

        IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause('rs.item_revision = :rcv_tree_rev', 'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_rev', inv_mwb_globals.g_tree_rev);
        END IF;

        IF inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
           inv_mwb_query_manager.add_where_clause('rss.lot_num = :rcv_lot_num', 'RECEIVING');
           inv_mwb_query_manager.add_bind_variable('rcv_lot_num', inv_mwb_globals.g_tree_lot_number);
        END IF;

	inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
        inv_mwb_query_manager.add_where_clause('rs.item_id = :rcv_tree_item_id', 'RECEIVING');
        inv_mwb_query_manager.add_where_clause('rss.serial_num = :rcv_tree_serial_num', 'RECEIVING');

        inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
        inv_mwb_query_manager.add_bind_variable('rcv_tree_item_id', inv_mwb_globals.g_tree_item_id);
        inv_mwb_query_manager.add_bind_variable('rcv_tree_serial_num', inv_mwb_globals.g_tree_serial_number);

     END IF;
   inv_mwb_query_manager.execute_query;
END IF;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END serial_node_event;

  --
  -- public functions
  --


 PROCEDURE matloc_node_event(
   x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
 )
 IS
   i                    NUMBER                                                := 1;
   j                    NUMBER                                                := 1;
   query_str            VARCHAR2(4000);

   grade_f     mtl_material_status_history.grade_code%TYPE ;    -- NSRIVAST, INVCONV
   l_procedure_name VARCHAR2(30);

   TYPE lookup_meaning_table IS TABLE OF mfg_lookups.meaning%TYPE
   INDEX BY BINARY_INTEGER;

    document_type_meaning   lookup_meaning_table;
    ctr_lookup_code number := 1;
  BEGIN
      l_procedure_name := 'MATLOC_NODE_EVENT';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
      SELECT meaning
      BULK COLLECT INTO document_type_meaning
      FROM mfg_lookups
      WHERE lookup_type = 'MTL_DOCUMENT_TYPES'
      ORDER BY lookup_code;

   IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
       IF inv_mwb_globals.g_tree_mat_loc_id = 1
       OR inv_mwb_globals.g_tree_mat_loc_id = 2
       THEN
         inv_mwb_tree1.add_subs(
                        x_node_value
                       , x_node_tbl
                       , x_tbl_index
                       );

    IF inv_mwb_globals.g_tree_mat_loc_id = 2
    THEN

         inv_mwb_globals.g_locator_controlled := 2;

         inv_mwb_tree1.add_lpns(
                        x_node_value
                       , x_node_tbl
                       , x_tbl_index
                       );

         IF  inv_mwb_globals.g_lpn_from IS NULL
         AND inv_mwb_globals.g_lpn_to IS NULL THEN

            inv_mwb_globals.g_containerized := 1;
            inv_mwb_globals.g_locator_controlled := 2;
            IF inv_mwb_globals.g_tree_node_type = 'MATLOC' THEN
               inv_mwb_globals.g_inserted_under_org := 'Y';
            ELSE
               inv_mwb_globals.g_inserted_under_org := 'N';
            END IF;

            inv_mwb_tree1.add_items(
                           x_node_value
                          , x_node_tbl
                          , x_tbl_index
                          );

         END IF;
    END IF;
    ELSIF inv_mwb_globals.g_tree_mat_loc_id = 3 then
         IF    inv_mwb_globals.g_shipment_header_id_interorg IS NOT NULL
            OR inv_mwb_globals.g_req_header_id IS NOT NULL
            OR inv_mwb_globals.g_shipment_header_id_asn IS NOT NULL
            OR inv_mwb_globals.g_po_header_id IS NOT NULL
         THEN
            ctr_lookup_code := 1;

            IF inv_mwb_globals.g_po_header_id IS NOT NULL
            THEN
               /* add PO as the document type */
               x_node_tbl (i).state := -1;
               x_node_tbl (i).DEPTH := 1;
               x_node_tbl (i).label := document_type_meaning(1);
               x_node_tbl (i).icon := 'tree_account';
               x_node_tbl (i).VALUE := 1;
               x_node_tbl (i).TYPE := 'DOCTYPE';
               i := i + 1;
            END IF;

            IF inv_mwb_globals.g_req_header_id IS NOT NULL
            THEN
               x_node_tbl (i).state := -1;
               x_node_tbl (i).DEPTH := 1;
               x_node_tbl (i).label := document_type_meaning (2);
               x_node_tbl (i).icon := 'tree_account';
               x_node_tbl (i).VALUE := 2;
               x_node_tbl (i).TYPE := 'DOCTYPE';
               i := i + 1;
            END IF;

            IF inv_mwb_globals.g_shipment_header_id_interorg IS NOT NULL
            THEN
               x_node_tbl (i).state := -1;
               x_node_tbl (i).DEPTH := 1;
               x_node_tbl (i).label := document_type_meaning (3);
               x_node_tbl (i).icon := 'tree_account';
               x_node_tbl (i).VALUE := 3;
               x_node_tbl (i).TYPE := 'DOCTYPE';
               i := i + 1;
            END IF;

            IF inv_mwb_globals.g_shipment_header_id_asn IS NOT NULL
            THEN
               /* add ASN as the document type */
               x_node_tbl (i).state := -1;
               x_node_tbl (i).DEPTH := 1;
               x_node_tbl (i).label := document_type_meaning (4);
               x_node_tbl (i).icon := 'tree_account';
               x_node_tbl (i).VALUE := 4;
               x_node_tbl (i).TYPE := 'DOCTYPE';
               i := i + 1;
            END IF;
         ELSE
            FOR i IN 1 .. document_type_meaning .COUNT
            LOOP
               x_node_tbl (i).state := -1;
               x_node_tbl (i).DEPTH := 1;
               x_node_tbl (i).label := document_type_meaning (i);
               x_node_tbl (i).icon := 'tree_account';
               x_node_tbl (i).VALUE := i;
               x_node_tbl (i).TYPE := 'DOCTYPE';
            END LOOP;
         END IF;
      END IF;

    ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Tree Node Selected' );
      CASE inv_mwb_globals.g_tree_mat_loc_id
         WHEN 1 THEN
            IF inv_mwb_globals.g_serial_from IS NOT NULL
            OR inv_mwb_globals.g_serial_to IS NOT NULL
            OR inv_mwb_globals.g_status_id IS NOT NULL -- Bug 6060233
	    OR inv_mwb_globals.g_serial_attr_query IS NOT NULL THEN		-- Bug 6429880
               make_common_query_onhand('MSN_QUERY');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'msn.current_subinventory_code';
               inv_mwb_query_manager.add_group_clause('msn.current_subinventory_code', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.current_organization_id = :onh_tree_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND_MSN');
            ELSE
               make_common_query_onhand('MOQD');
               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                  'moqd.subinventory_code';
               inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
               inv_mwb_query_manager.add_qf_where_onhand('ONHAND');
            END IF;
         WHEN  2 THEN
            make_common_query_receiving('RECEIVING');
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
               'rs.to_subinventory';
            inv_mwb_query_manager.add_group_clause('rs.to_subinventory', 'RECEIVING');
            inv_mwb_query_manager.add_where_clause('rs.to_organization_id = :rcv_tree_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_bind_variable('rcv_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_qf_where_receiving('RECEIVING');
         WHEN 3 THEN
            make_common_query_inbound('INBOUND');
            inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Going to add po_header_id in select');
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_HEADER_ID).column_value :=
               'ms.po_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REQ_HEADER_ID).column_value :=
               'ms.req_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.add_group_clause('ms.po_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.req_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_qf_where_inbound('INBOUND');
         END CASE;
         inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Going to build and execute the query');
         inv_mwb_query_manager.execute_query;
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
   END matloc_node_event;


 PROCEDURE doc_type_node_event(
     x_node_value          IN OUT NOCOPY NUMBER
   , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
   , x_tbl_index           IN OUT NOCOPY NUMBER
   )
   IS
      i                    NUMBER                                                := 1;
      j                    NUMBER                                                := 1;
      l_procedure_name VARCHAR2(30);
   BEGIN
      l_procedure_name := 'DOC_TYPE_NODE_EVENT';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         inv_mwb_tree1.add_document_numbers(
                        x_node_value
                       , x_node_tbl
                       , x_tbl_index
                       );
      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
         make_common_query_inbound('INBOUND');
         inv_mwb_query_manager.add_qf_where_inbound('INBOUND');

         CASE inv_mwb_globals.g_tree_doc_type_id
            WHEN 1 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_HEADER_ID).column_value :=
                  'ms.po_header_id';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.RELEASE_NUMBER).column_value :=
                  'ms.po_release_id';
               inv_mwb_query_manager.add_group_clause('ms.po_release_id', 'INBOUND');
               inv_mwb_query_manager.add_group_clause('ms.po_header_id', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''PO''', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.po_header_id IS NOT NULL', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            WHEN 2 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REQ_HEADER_ID).column_value :=
                  'ms.req_header_id';
               inv_mwb_query_manager.add_group_clause('ms.req_header_id', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.supply_type_code IN (''REQ'',''SHIPMENT'')', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.req_header_id is not null', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
               inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            WHEN 3 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
                  'ms.shipment_header_id';
               inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.req_header_id IS NULL', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NULL', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('rsh.RECEIPT_SOURCE_CODE = ''INVENTORY''', 'INBOUND');
            WHEN 4 THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
                  'ms.shipment_header_id';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_ID).column_value :=
                  'rsh.vendor_id';
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_SITE_ID).column_value :=
                  'rsh.vendor_site_id';
               inv_mwb_query_manager.add_group_clause('rsh.vendor_id', 'INBOUND');
               inv_mwb_query_manager.add_group_clause('rsh.vendor_site_id', 'INBOUND');
               inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NOT NULL', 'INBOUND');
               inv_mwb_query_manager.add_where_clause('rsh.RECEIPT_SOURCE_CODE = ''VENDOR''', 'INBOUND');
         END CASE;
      inv_mwb_query_manager.execute_query;
   END IF;
END doc_type_node_event;

   PROCEDURE doc_num_node_event(
        x_node_value          IN OUT NOCOPY NUMBER
      , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
      , x_tbl_index           IN OUT NOCOPY NUMBER
      )
   IS
      l_procedure_name VARCHAR2(30);
      l_po_header_id   NUMBER;
      l_req_header_id  NUMBER;
      l_shipment_header_id NUMBER;
   BEGIN
      l_procedure_name := 'DOC_NUM_NODE_EVENT';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_EXPANDED' THEN
         IF (inv_mwb_globals.g_tree_doc_type_id <> 1) THEN
            inv_mwb_tree1.add_lpns(
                                x_node_value
                              , x_node_tbl
                              , x_tbl_index
                              );
         END IF;

         IF  inv_mwb_globals.g_lpn_from IS NULL
         AND inv_mwb_globals.g_lpn_to IS NULL THEN
            inv_mwb_tree1.add_items(
                                x_node_value
                              , x_node_tbl
                              , x_tbl_index
                              );
         END IF;

      ELSIF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN

         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
            'ms.intransit_owning_org_id';
         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.EXPECTED_RECEIPT_DATE).column_value :=
            'ms.expected_delivery_date';
         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.FROM_ORG_ID).column_value :=
            'ms.from_organization_id';
         inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
         inv_mwb_query_manager.add_group_clause('ms.expected_delivery_date', 'INBOUND');
         inv_mwb_query_manager.add_group_clause('ms.from_organization_id', 'INBOUND');
         make_common_query_inbound('INBOUND');
         inv_mwb_query_manager.add_qf_where_inbound('INBOUND');

         CASE inv_mwb_globals.g_tree_doc_type_id
         WHEN 1 THEN
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_NUMBER).column_value :=
            inv_mwb_globals.g_tree_node_value;
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_HEADER_ID).column_value :=
               'ms.po_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.po_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.PO_RELEASE_ID).column_value :=
               'ms.po_release_id';

            inv_mwb_query_manager.add_group_clause('ms.po_release_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.po_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.po_line_id', 'INBOUND');

            inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''PO''', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.po_header_id = :po_header_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
            inv_mwb_query_manager.add_bind_variable('po_header_id', inv_mwb_globals.g_tree_node_value);

         WHEN 2 THEN
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.REQ_HEADER_ID).column_value :=
               'ms.req_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.req_line_id';

            inv_mwb_query_manager.add_group_clause('ms.req_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.req_line_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.supply_type_code IN (''REQ'',''SHIPMENT'')', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.req_header_id = :req_header_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.to_organization_id = :inb_tree_organization_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('req_header_id', inv_mwb_globals.g_tree_node_value);
            inv_mwb_query_manager.add_bind_variable('inb_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
         WHEN 3 THEN
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.shipment_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'rsl.asn_lpn_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.OWNING_ORG_ID).column_value :=
               'ms.intransit_owning_org_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
               'rsh.shipped_date';

            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.intransit_owning_org_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rsh.shipped_date', 'INBOUND');

            inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NULL', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.shipment_header_id = :inb_shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('inb_shipment_header_id', inv_mwb_globals.g_tree_doc_header_id);

         WHEN 4 THEN
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPMENT_HEADER_ID_ASN).column_value :=
               'ms.shipment_header_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.DOCUMENT_LINE_NUMBER).column_value :=
               'ms.shipment_line_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_ID).column_value :=
               'rsh.vendor_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.VENDOR_SITE_ID).column_value :=
               'rsh.vendor_site_id';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.SHIPPED_DATE).column_value :=
               'rsh.shipped_date';
            inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.LPN_ID).column_value :=
               'rsl.asn_lpn_id';

            inv_mwb_query_manager.add_group_clause('rsh.vendor_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rsh.vendor_site_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_header_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('ms.shipment_line_id', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rsh.shipped_date', 'INBOUND');
            inv_mwb_query_manager.add_group_clause('rsl.asn_lpn_id', 'INBOUND');

            inv_mwb_query_manager.add_where_clause('ms.supply_type_code = ''SHIPMENT''', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('rsh.ASN_TYPE IS NOT NULL', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('rsh.RECEIPT_SOURCE_CODE = ''VENDOR''', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('ms.shipment_header_id = :shipment_num', 'INBOUND');
            inv_mwb_query_manager.add_bind_variable('shipment_num', inv_mwb_globals.g_tree_node_value);

         END CASE;
         inv_mwb_query_manager.execute_query;
      END IF; -- Tree node selected /expanded.
   END doc_num_node_event;

   PROCEDURE make_common_query_onhand(p_flag VARCHAR2) IS
     l_procedure_name VARCHAR2(30);
   BEGIN
      l_procedure_name := 'MAKE_COMMON_QUERY_ONHAND';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
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

               inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');

               inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.inventory_item_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('''Ea''', 'ONHAND');

               IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
               OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN

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

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_organization_id).column_value :=
                     'msn.owning_organization_id';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_organization_id).column_value :=
                     'msn.planning_organization_id';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_tp_type).column_value :=
                     'msn.owning_tp_type';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_tp_type).column_value :=
                     'msn.planning_tp_type';

                  inv_mwb_query_manager.add_group_clause('msn.serial_number', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('msn.owning_organization_id', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('msn.planning_organization_id', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('msn.owning_tp_type', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('msn.planning_tp_type', 'ONHAND');

	      END IF;


            WHEN 'MOQD' THEN

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                  'moqd.inventory_item_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
                  'moqd.organization_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
                  'SUM(moqd.primary_transaction_quantity)';

               inv_mwb_query_manager.add_from_clause('mtl_onhand_quantities_detail moqd', 'ONHAND');

               inv_mwb_query_manager.add_group_clause('moqd.organization_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('moqd.inventory_item_id', 'ONHAND');

               IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
               OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                     'SUM(DECODE(moqd.containerized_flag, 1, moqd.primary_transaction_quantity, 0))';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                     'SUM(DECODE(moqd.containerized_flag, 1, 0, moqd.primary_transaction_quantity))';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UOM_CODE).column_value :=
                     'moqd.secondary_uom_code';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_organization_id).column_value :=
                     'moqd.owning_organization_id';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_organization_id).column_value :=
                     'moqd.planning_organization_id';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.owning_tp_type).column_value :=
                     'moqd.owning_tp_type';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.planning_tp_type).column_value :=
                     'moqd.planning_tp_type';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_ONHAND).column_value :=
                     'SUM(moqd.secondary_transaction_quantity)';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_PACKED).column_value :=
                     'SUM(DECODE(moqd.containerized_flag, 1, moqd.secondary_transaction_quantity, 0))';

                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SECONDARY_UNPACKED).column_value :=
                     'SUM(DECODE(moqd.containerized_flag, 1, 0, moqd.secondary_transaction_quantity))';

                  inv_mwb_query_manager.add_group_clause('moqd.secondary_uom_code', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('moqd.owning_organization_id', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('moqd.planning_organization_id', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('moqd.owning_tp_type', 'ONHAND');
                  inv_mwb_query_manager.add_group_clause('moqd.planning_tp_type', 'ONHAND');

	       END IF;

            WHEN 'MSN_QUERY' THEN


               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ITEM_ID).column_value :=
                  'msn.inventory_item_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ORG_ID).column_value :=
                  'msn.current_organization_id';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
                  '''Ea''';

               inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.ONHAND).column_value :=
                  'count(1)';

               inv_mwb_query_manager.add_group_clause('msn.inventory_item_id' , 'ONHAND');
               inv_mwb_query_manager.add_group_clause('msn.current_organization_id', 'ONHAND');
               inv_mwb_query_manager.add_group_clause('''Ea''', 'ONHAND');

               inv_mwb_query_manager.add_from_clause('mtl_serial_numbers msn', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_status = 3', 'ONHAND');

               IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
               OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.PACKED).column_value :=
                     'sum(decode(msn.lpn_id,NULL,0, 1))';
                  inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.UNPACKED).column_value :=
                     'sum(decode(msn.lpn_id,NULL,1, 0))';
               END IF;

         END CASE; -- p_flag
      END IF; -- End if for onhand
   END make_common_query_onhand;

   PROCEDURE make_common_query_inbound(p_flag VARCHAR2) IS
      l_procedure_name VARCHAR2(30);
      l_lot_control   NUMBER;
   BEGIN
      l_procedure_name := 'MAKE_COMMON_QUERY_INBOUND';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
      IF(inv_mwb_globals.g_chk_inbound = 1 AND p_flag = 'INBOUND') THEN

         IF inv_mwb_globals.g_tree_item_id IS NOT NULL THEN
            SELECT lot_control_code
              INTO l_lot_control
              FROM mtl_system_items
             WHERE inventory_item_id = inv_mwb_globals.g_tree_item_id
         AND organization_id = inv_mwb_globals.g_tree_organization_id;
         END IF;

         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.ITEM_ID).column_value :=
            'ms.item_id';
         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.ORG_ID).column_value :=
            'ms.to_organization_id';
         -- for bug 8420731
         -- for bug 8420783
         -- for bug 8414727
         IF (inv_mwb_globals.g_serial_from IS NOT NULl or inv_mwb_globals.g_serial_to is NOT NULL) THEN
               inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
               'COUNT(1)';
         ELSIF(inv_mwb_globals.g_lot_from IS NOT NULl or inv_mwb_globals.g_lot_to is NOT NULL ) THEN
           inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
           'SUM(rls.quantity)';
         ELSE
           inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.INBOUND).column_value :=
           'SUM(ms.to_org_primary_quantity)';
         END IF;
         -- end of bug 8414727
         -- end of bug 8420783
         -- end of bug 8420731
--bug 4761399
--         inv_mwb_query_manager.g_inbound_select(inv_mwb_query_manager.CG_ID).column_value :=
--           'ms.cost_group_id';

         inv_mwb_query_manager.add_group_clause('ms.item_id','INBOUND');
         inv_mwb_query_manager.add_group_clause('ms.to_organization_id','INBOUND');
--         inv_mwb_query_manager.add_group_clause('ms.cost_group_id', 'INBOUND');
         inv_mwb_query_manager.add_where_clause('ms.destination_type_code = ''INVENTORY''', 'INBOUND');
         inv_mwb_query_manager.add_where_clause('ms.supply_type_code <> ''RECEIVING''', 'INBOUND');

      END IF;
   END make_common_query_inbound;

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

            IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
            OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.UNPACKED).column_value :=
                 'SUM(DECODE (rs.lpn_id, null, rs.to_org_primary_quantity, 0))';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PACKED).column_value :=
                 'SUM(DECODE (rs.lpn_id, null, 0, rs.to_org_primary_quantity))';
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
               'rs.item_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'rs.to_organization_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
               '''Ea''';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.receiving).column_value :=
               'count(1)';

            inv_mwb_query_manager.add_group_clause('rs.to_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.item_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('''Ea''', 'RECEIVING');

            IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
            OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PACKED).column_value :=
                  'DECODE(rs.lpn_id, NULL, 0,1)';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.UNPACKED).column_value :=
                  'DECODE(rs.lpn_id, NULL, 1,0)';
            END IF;

         ELSIF p_flag = 'MSN_QUERY' THEN
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ITEM_ID).column_value :=
               'rs.item_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.ORG_ID).column_value :=
               'rs.to_organization_id';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PRIMARY_UOM_CODE).column_value :=
               '''Ea''';
            inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.receiving).column_value :=
               'count(1)';
            inv_mwb_query_manager.add_group_clause('rs.item_id' , 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('rs.to_organization_id', 'RECEIVING');
            inv_mwb_query_manager.add_group_clause('''Ea''', 'RECEIVING');

            IF inv_mwb_globals.g_multiple_loc_selected = 'FALSE'
            OR inv_mwb_globals.g_tree_node_type <> 'APPTREE_OBJECT_TRUNK' THEN
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.PACKED).column_value :=
                  'sum(decode(rs.lpn_id,NULL,0, 1))';
               inv_mwb_query_manager.g_receiving_select(inv_mwb_query_manager.UNPACKED).column_value :=
                  'sum(decode(rs.lpn_id,NULL,1, 0))';
            END IF;
	 END IF;
      END IF; -- End if for receiving
   END make_common_query_receiving;

  PROCEDURE event (
            x_node_value IN OUT NOCOPY NUMBER
           ,x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY NUMBER
           ) IS

     l_procedure_name VARCHAR2(30);

  BEGIN

     l_procedure_name := 'EVENT';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered EVENT with node_type :'||inv_mwb_globals.g_tree_node_type);

      IF inv_mwb_globals.g_tree_node_type = 'MATLOC' THEN
         inv_mwb_globals.g_inserted_under_org := 'Y';
      ELSE
         inv_mwb_globals.g_inserted_under_org := 'N';
      END IF;

     CASE inv_mwb_globals.g_tree_node_type

        WHEN 'APPTREE_OBJECT_TRUNK' THEN

           root_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
               );

        WHEN 'ORG' THEN

           org_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
               );

        WHEN 'MATLOC' THEN

           matloc_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
                );

        WHEN 'DOCTYPE' THEN

           doc_type_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
               );

        WHEN 'DOCNUM' THEN

           doc_num_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
               );

        WHEN 'SUB' THEN

           sub_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
               );

        WHEN 'LOC' THEN

           loc_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
               );

        WHEN 'ITEM' THEN

           item_node_event(
                x_node_value
               ,x_node_tbl
               ,x_tbl_index
               );

        WHEN 'REV' THEN

           IF NVL(inv_mwb_globals.g_tree_doc_type_id,-99) <> 1 THEN
              rev_node_event(
                   x_node_value
                  ,x_node_tbl
                  ,x_tbl_index
                  );
           END IF;

        WHEN 'LPN' THEN

           IF NVL(inv_mwb_globals.g_tree_doc_type_id,-99) <> 1 THEN
              lpn_node_event(
                   x_node_value
                  ,x_node_tbl
                  ,x_tbl_index
                  );
            END IF;

        WHEN 'LOT' THEN

           IF NVL(inv_mwb_globals.g_tree_doc_type_id,-99) <> 1 THEN
              lot_node_event(
                   x_node_value
                  ,x_node_tbl
                  ,x_tbl_index
                  );
           END IF;

        WHEN 'SERIAL' THEN

           IF NVL(inv_mwb_globals.g_tree_doc_type_id,-99) <> 1 THEN
              serial_node_event(
                   x_node_value
                  ,x_node_tbl
                  ,x_tbl_index
                  );
           END IF;

     END CASE;

  END event;

END inv_mwb_location_tree;

/
