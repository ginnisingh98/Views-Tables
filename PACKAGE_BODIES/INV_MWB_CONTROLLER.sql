--------------------------------------------------------
--  DDL for Package Body INV_MWB_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_CONTROLLER" AS
/* $Header: INVMWCTB.pls 120.19.12010000.5 2009/11/30 14:43:01 ksaripal ship $ */

   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_CONTROLLER';

   /*
    * Forward declarations of functions
    */
   PROCEDURE initialize;

   PROCEDURE PROCESS_QUERY(
           p_organization_id              IN NUMBER
         , p_organization_code            IN VARCHAR2
         , p_locator_name                 IN VARCHAR2
         , p_item_name                    IN VARCHAR2
         , p_cost_group                   IN VARCHAR2
         , p_project_number               IN VARCHAR2
         , p_task_number                  IN VARCHAR2
         , p_owning_party                 IN VARCHAR2
         , p_planning_party               IN VARCHAR2
         , p_lpn_state                    IN VARCHAR2
         , p_status                       IN VARCHAR2
         , p_subinventory_code            IN VARCHAR2
         , p_locator_id                   IN NUMBER
         , p_client_code                  IN VARCHAR2                      -- ER(9158529 client)
         , p_inventory_item_id            IN NUMBER
         , p_revision                     IN VARCHAR2
         , p_status_id                    IN NUMBER
         , p_cost_group_id                IN NUMBER
         , p_category_set_id              IN NUMBER                        -- ER(9158529)
         , p_category_id                  IN NUMBER                        -- ER(9158529)
         , p_lpn_from                     IN VARCHAR2
         , p_lpn_from_id                  IN NUMBER
         , p_lpn_to                       IN VARCHAR2
         , p_lpn_to_id                    IN NUMBER
         , p_lot_from                     IN VARCHAR2
         , p_lot_to                       IN VARCHAR2
         , p_supplier_lot_from            IN VARCHAR2                       -- Bug 8396954
         , p_supplier_lot_to              IN VARCHAR2                       -- Bug 8396954
         , p_serial_from                  IN VARCHAR2
         , p_serial_to                    IN VARCHAR2
         , p_workbench_vb                 IN NUMBER
         , p_prepacked                    IN VARCHAR2
         , p_project_id                   IN NUMBER
         , p_task_id                      IN NUMBER
         , p_unit_number                  IN NUMBER
         , p_planning_org                 IN VARCHAR2
         , p_owning_org                   IN VARCHAR2
         , p_po_header_id                 IN NUMBER
         , p_po_release_id                IN NUMBER
         , p_shipment_header_id_asn       IN NUMBER
         , p_shipment_header_id_interorg  IN NUMBER
         , p_req_header_id                IN NUMBER
         , p_vendor_id                    IN NUMBER
         , p_vendor_site_id               IN NUMBER
         , p_source_org_id                IN NUMBER
         , p_chk_inbound                  IN NUMBER
         , p_chk_receiving                IN NUMBER
         , p_chk_onhand                   IN NUMBER
         , p_include_po_without_asn       IN NUMBER
         , p_expected_from_date           IN DATE
         , p_expected_to_date             IN DATE
         , p_internal_order_id            IN NUMBER
         , p_vendor_item                  IN VARCHAR2
         , p_grade_from                   IN VARCHAR2
         , p_planning_query_mode          IN NUMBER
         , p_owning_query_mode            IN NUMBER
         , p_wms_enabled_flag             IN NUMBER
         , p_subinventory_type            IN NUMBER
         , p_rcv_query_mode               IN NUMBER
         , p_detailed                     IN NUMBER
         , p_item_description             IN VARCHAR2
         , p_qty_from                     IN NUMBER
         , p_qty_to                       IN NUMBER
         , p_view_by                      IN VARCHAR2
         , p_locator_control_code         IN NUMBER
         , p_wms_installed_flag           IN NUMBER
         , p_check                        IN NUMBER
	 , p_serial_attr_query		  IN VARCHAR2			--	Bug 6429880
         , p_lot_attr_query               IN VARCHAR2                   --      Bug 7566588
         , p_responsibility_id            IN NUMBER
         , p_resp_application_id          IN NUMBER
         , p_is_projects_enabled_org      IN NUMBER
         ,p_expired_lots                  IN VARCHAR2
	 ,p_expiration_date               IN DATE
	 ,p_parent_lot			  IN VARCHAR2			--	BUG 7556505
	 ,p_shipment_header_id            IN  NUMBER        -- Bug 6633612
         ) IS

      l_procedure_name VARCHAR2(30);

   BEGIN

      l_procedure_name := 'PROCESS_QUERY';

      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered' );

      inv_mwb_globals.g_organization_id             := p_organization_id;
      inv_mwb_globals.g_subinventory_code           := p_subinventory_code;
      inv_mwb_globals.g_locator_id                  := p_locator_id;
      inv_mwb_globals.g_client_code                 := p_client_code;                   -- ER(9158529 client)
      inv_mwb_globals.g_inventory_item_id           := p_inventory_item_id;
      inv_mwb_globals.g_revision                    := p_revision;
      inv_mwb_globals.g_status_id                   := p_status_id;
      inv_mwb_globals.g_cost_group_id               := p_cost_group_id;
      inv_mwb_globals.g_category_set_id             := p_category_set_id;               -- ER(9158529)
      inv_mwb_globals.g_category_id                 := p_category_id;                   -- ER(9158529)
      inv_mwb_globals.g_lpn_from                    := p_lpn_from;
      inv_mwb_globals.g_lpn_from_id                 := p_lpn_from_id;
      inv_mwb_globals.g_lpn_to                      := p_lpn_to;
      inv_mwb_globals.g_lpn_to_id                   := p_lpn_to_id;
      inv_mwb_globals.g_lot_from                    := p_lot_from;
      inv_mwb_globals.g_lot_to                      := p_lot_to;
      inv_mwb_globals.g_supplier_lot_from           := p_supplier_lot_from;             -- Bug 8396954
      inv_mwb_globals.g_supplier_lot_to             := p_supplier_lot_to;               -- Bug 8396954
      inv_mwb_globals.g_serial_from                 := p_serial_from;
      inv_mwb_globals.g_serial_to                   := p_serial_to;
      inv_mwb_globals.g_workbench_vb                := p_workbench_vb;
      inv_mwb_globals.g_prepacked                   := p_prepacked;
      inv_mwb_globals.g_project_id                  := p_project_id;
      inv_mwb_globals.g_task_id                     := p_task_id;
      inv_mwb_globals.g_unit_number                 := p_unit_number;
      inv_mwb_globals.g_planning_org                := p_planning_org;
      inv_mwb_globals.g_owning_org                  := p_owning_org;
      inv_mwb_globals.g_po_header_id                := p_po_header_id;
      inv_mwb_globals.g_po_release_id               := p_po_release_id;
      inv_mwb_globals.g_shipment_header_id_asn      := p_shipment_header_id_asn;
      inv_mwb_globals.g_shipment_header_id_interorg := p_shipment_header_id_interorg;
      inv_mwb_globals.g_req_header_id               := p_req_header_id;
      inv_mwb_globals.g_vendor_id                   := p_vendor_id;
      inv_mwb_globals.g_vendor_site_id              := p_vendor_site_id;
      inv_mwb_globals.g_source_org_id               := p_source_org_id;
      inv_mwb_globals.g_chk_inbound                 := p_chk_inbound;
      inv_mwb_globals.g_chk_receiving               := p_chk_receiving;
      inv_mwb_globals.g_chk_onhand                  := p_chk_onhand;
      inv_mwb_globals.g_include_po_without_asn      := p_include_po_without_asn;
      inv_mwb_globals.g_expected_from_date          := p_expected_from_date;
      inv_mwb_globals.g_expected_to_date            := p_expected_to_date;
      inv_mwb_globals.g_internal_order_id           := p_internal_order_id;
      inv_mwb_globals.g_vendor_item                 := p_vendor_item;
      inv_mwb_globals.g_grade_from_code             := p_grade_from;
      inv_mwb_globals.g_planning_query_mode         := p_planning_query_mode;
      inv_mwb_globals.g_owning_qry_mode             := p_owning_query_mode;
      inv_mwb_globals.g_wms_enabled_flag            := p_wms_enabled_flag;
      inv_mwb_globals.g_sub_type                    := p_subinventory_type;
      inv_mwb_globals.g_rcv_query_mode              := p_rcv_query_mode;
      inv_mwb_globals.g_detailed                    := p_detailed;
      inv_mwb_globals.g_item_description            := p_item_description;
      inv_mwb_globals.g_qty_from                    := p_qty_from;
      inv_mwb_globals.g_qty_to                      := p_qty_to;
      inv_mwb_globals.g_view_by                     := p_view_by;
      inv_mwb_globals.g_locator_control_code        := p_locator_control_code;
      inv_mwb_globals.g_wms_installed_flag          := p_wms_installed_flag;
      inv_mwb_globals.g_check                       := p_check;
      inv_mwb_globals.g_serial_attr_query	    := p_serial_attr_query;		-- Bug 6429880
      inv_mwb_globals.g_lot_attr_query              := p_lot_attr_query;                -- Bug 7566588
      inv_mwb_globals.g_responsibility_id           := p_responsibility_id;
      inv_mwb_globals.g_resp_application_id         := p_resp_application_id;
      inv_mwb_globals.g_is_projects_enabled_org     := p_is_projects_enabled_org;
      inv_mwb_globals.g_organization_code           := p_organization_code;
      inv_mwb_globals.g_locator_name                := p_locator_name;
      inv_mwb_globals.g_item_name                   := p_item_name;
      inv_mwb_globals.g_cost_group                  := p_cost_group;
      inv_mwb_globals.g_project_number              := p_project_number;
      inv_mwb_globals.g_task_number                 := p_task_number;
      inv_mwb_globals.g_owning_party                := p_owning_party;
      inv_mwb_globals.g_planning_party              := p_planning_party;
      inv_mwb_globals.g_lpn_state                   := p_lpn_state;
      inv_mwb_globals.g_status                      := p_status;
      --KMOTUPAL ME # 3922793
      inv_mwb_globals.g_expired_lots                := p_expired_lots;
      inv_mwb_globals.g_expiration_date             := p_expiration_date;
      inv_mwb_globals.g_parent_lot		    := p_parent_lot;			-- BUG 7556505
      inv_mwb_globals.g_shipment_header_id          := p_shipment_header_id;  -- Bug 6633612


      IF (inv_mwb_globals.g_chk_onhand = 1
          AND inv_mwb_globals.g_chk_receiving = 1)
      OR  (inv_mwb_globals.g_chk_onhand = 1
          AND inv_mwb_globals.g_chk_inbound = 1)
      OR  (inv_mwb_globals.g_chk_receiving = 1
          AND inv_mwb_globals.g_chk_inbound = 1)
      THEN
         inv_mwb_globals.g_multiple_loc_selected := 'TRUE';
      ELSE
         inv_mwb_globals.g_multiple_loc_selected := 'FALSE';
      END IF;


      inv_mwb_globals.print_parameters;

   END PROCESS_QUERY;

   PROCEDURE SET_TREE_GLOBALS(
           p_tree_organization_id   IN NUMBER
         , p_view_by                IN VARCHAR2
         , p_tree_subinventory_code IN VARCHAR2
         , p_tree_loc_id            IN NUMBER
         , p_tree_item_id           IN NUMBER
         , p_tree_plpn_id           IN NUMBER
         , p_tree_mat_loc_id        IN NUMBER
         , p_tree_doc_type_id       IN NUMBER
         , p_tree_doc_num           IN VARCHAR2
         , p_tree_doc_header_id     IN NUMBER
         , p_tree_st_id             IN NUMBER
         , p_tree_rev               IN VARCHAR2
         , p_tree_cg_id             IN VARCHAR2
         , p_tree_grade             IN VARCHAR2
  	      , p_tree_lot		    IN VARCHAR2
         , p_tree_serial            IN VARCHAR2
         , p_tree_node_type         IN VARCHAR2
         , p_tree_node_value        IN VARCHAR2
         , p_tree_node_state        IN NUMBER
         , p_tree_node_high_value   IN NUMBER
         , p_tree_node_low_value    IN NUMBER
	 , p_tree_serial_attr_query IN VARCHAR2		--	Bug 6429880
         , p_tree_lot_attr_query    IN VARCHAR2         --      Bug 7566588
         , p_tree_event             IN VARCHAR2
         , p_tree_attribute_qf_lot  IN VARCHAR2
         , p_attribute_qf_serial    IN VARCHAR2
         , p_query_lot_attr         IN VARCHAR2
         , p_query_serial_attr      IN VARCHAR2
	 , p_is_containerized       IN NUMBER
 ) IS

      l_procedure_name CONSTANT VARCHAR2(30) := 'SET_TREE_GLOBALS';

   BEGIN

       inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered' );

       inv_mwb_globals.g_tree_organization_id     := p_tree_organization_id;
       inv_mwb_globals.g_tree_loc_id              := p_tree_loc_id;
       inv_mwb_globals.g_tree_subinventory_code   := p_tree_subinventory_code;
       inv_mwb_globals.g_tree_item_id             := p_tree_item_id;
       inv_mwb_globals.g_tree_parent_lpn_id       := p_tree_plpn_id;
       inv_mwb_globals.g_tree_mat_loc_id          := p_tree_mat_loc_id;
       inv_mwb_globals.g_tree_doc_type_id         := p_tree_doc_type_id;
       inv_mwb_globals.g_tree_doc_num             := p_tree_doc_num;
       inv_mwb_globals.g_tree_doc_header_id       := p_tree_doc_header_id;
       inv_mwb_globals.g_tree_st_id               := p_tree_st_id;
       inv_mwb_globals.g_tree_rev                 := p_tree_rev;
       inv_mwb_globals.g_tree_cg_id               := p_tree_cg_id;
       inv_mwb_globals.g_tree_grade_code          := p_tree_grade;
       inv_mwb_globals.g_tree_lot_number          := p_tree_lot;
       inv_mwb_globals.g_tree_serial_number       := p_tree_serial;
       inv_mwb_globals.g_tree_node_type           := p_tree_node_type;
       inv_mwb_globals.g_tree_node_state          := p_tree_node_state;
       inv_mwb_globals.g_tree_node_high_value     := p_tree_node_high_value;
       inv_mwb_globals.g_tree_node_low_value      := p_tree_node_low_value;
       inv_mwb_globals.g_tree_node_value          := p_tree_node_value;
       inv_mwb_globals.g_view_by                  := p_view_by;
       inv_mwb_globals.g_tree_event               := p_tree_event;
       inv_mwb_globals.g_tree_serial_attr_query	  := p_tree_serial_attr_query;		--	Bug 6429880
       inv_mwb_globals.g_tree_lot_attr_query      := p_tree_lot_attr_query;             --      Bug 7566588
       inv_mwb_globals.g_tree_attribute_qf_lot    := p_tree_attribute_qf_lot;
       inv_mwb_globals.g_tree_attribute_qf_serial := p_attribute_qf_serial;
       inv_mwb_globals.g_tree_query_lot_attr      := p_query_lot_attr;
       inv_mwb_globals.g_tree_query_serial_attr   := p_query_serial_attr;
       inv_mwb_globals.g_containerized            := p_is_containerized;
       /*
        * Temp changes for testing
        */
       inv_mwb_globals.print_parameters;


   END SET_TREE_GLOBALS;


   PROCEDURE EVENT (
            x_node_value IN OUT NOCOPY  NUMBER
          , x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
          , x_tbl_index  IN OUT NOCOPY  NUMBER
   ) IS

      l_procedure_name CONSTANT VARCHAR2(30) := 'EVENT';
   BEGIN

      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Entered' );

      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, inv_mwb_globals.g_view_by );

      /*
       * Initialize engine
       * -- Truncate table
       * -- Initialize/reset the query engine..
       */
      inv_mwb_globals.g_revision_controlled := 0;
      inv_mwb_globals.g_lot_controlled := 0;
      inv_mwb_globals.g_locator_controlled := 0;
      inv_mwb_globals.g_inserted_under_org := 'N';

      IF inv_mwb_globals.g_tree_event = 'TREE_NODE_SELECTED' THEN
         initialize;
      END IF;

      CASE inv_mwb_globals.g_view_by

         WHEN 'LOCATION' THEN
            inv_mwb_location_tree.event(
                                  x_node_value
                                 ,x_node_tbl
                                 ,x_tbl_index
                                );
         WHEN 'ITEM' THEN
            inv_mwb_item_tree.event(
                              x_node_value
                             ,x_node_tbl
                             ,x_tbl_index
                             );
         WHEN 'COST_GROUP' THEN
            inv_mwb_cost_group_tree.event(
                              x_node_value
                             ,x_node_tbl
                             ,x_tbl_index
                             );
         WHEN 'STATUS' THEN
            inv_mwb_status_tree.event(
                              x_node_value
                             ,x_node_tbl
                             ,x_tbl_index
                             );
         WHEN 'LPN' THEN
            inv_mwb_lpn_tree.event(
                              x_node_value
                             ,x_node_tbl
                             ,x_tbl_index
                             );

         WHEN 'SERIAL' THEN
            inv_mwb_serial_tree.event(
                              x_node_value
                             ,x_node_tbl
                             ,x_tbl_index
                             );
         WHEN 'LOT' THEN
            inv_mwb_lot_tree.event(
                              x_node_value
                             ,x_node_tbl
                             ,x_tbl_index
                             );

         WHEN 'GRADE' THEN
            inv_mwb_grade_tree.event(
                              x_node_value
                             ,x_node_tbl
                             ,x_tbl_index
                             );
      END CASE;

   EXCEPTION
      WHEN OTHERS THEN
         inv_mwb_globals.print_msg(
                     g_pkg_name,
                     l_procedure_name,
                     DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                     );
         inv_mwb_globals.print_msg(
                     g_pkg_name,
                     l_procedure_name,
                     DBMS_UTILITY.FORMAT_ERROR_STACK
                     );
      RAISE;

   END EVENT;

   PROCEDURE initialize IS
   BEGIN

      DELETE FROM mtl_mwb_gtmp;
      inv_mwb_query_manager.initialize_union_query;
      inv_mwb_query_manager.initialize_onhand_query;
      inv_mwb_query_manager.initialize_inbound_query;
      inv_mwb_query_manager.initialize_receiving_query;

      inv_mwb_query_manager.initialize_onhand_1_query;
      inv_mwb_query_manager.initialize_inbound_1_query;
      inv_mwb_query_manager.initialize_receiving_1_query;

   END initialize;


   FUNCTION GET_LAST_QUERY RETURN LONG
   IS
      l_procedure_name CONSTANT VARCHAR2(30) := 'GET_LAST_QUERY';
   BEGIN
      inv_mwb_globals.print_msg( g_pkg_name, l_procedure_name, 'Entered');
      return inv_mwb_globals.g_last_query;
   END;

END INV_MWB_CONTROLLER;

/
