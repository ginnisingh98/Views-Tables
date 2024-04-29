--------------------------------------------------------
--  DDL for Package INV_MWB_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: INVMWCTS.pls 120.16.12010000.5 2009/11/30 14:41:47 ksaripal ship $ */

   PROCEDURE PROCESS_QUERY(
           p_organization_id              IN  NUMBER     DEFAULT NULL
         , p_organization_code            IN  VARCHAR2   DEFAULT NULL
         , p_locator_name                 IN  VARCHAR2   DEFAULT NULL
         , p_item_name                    IN  VARCHAR2   DEFAULT NULL
         , p_cost_group                   IN  VARCHAR2   DEFAULT NULL
         , p_project_number               IN  VARCHAR2   DEFAULT NULL
         , p_task_number                  IN  VARCHAR2   DEFAULT NULL
         , p_owning_party                 IN  VARCHAR2   DEFAULT NULL
         , p_planning_party               IN  VARCHAR2   DEFAULT NULL
         , p_lpn_state                    IN  VARCHAR2   DEFAULT NULL
         , p_status                       IN  VARCHAR2   DEFAULT NULL
         , p_subinventory_code            IN  VARCHAR2   DEFAULT NULL
         , p_locator_id                   IN  NUMBER     DEFAULT NULL
         , p_client_code                  IN  VARCHAR2   DEFAULT NULL               -- ER(9158529 client)
         , p_inventory_item_id            IN  NUMBER     DEFAULT NULL
         , p_revision                     IN  VARCHAR2   DEFAULT NULL
         , p_status_id                    IN  NUMBER     DEFAULT NULL
         , p_cost_group_id                IN  NUMBER     DEFAULT NULL
         , p_category_set_id              IN  NUMBER     DEFAULT NULL               -- ER(9158529)
         , p_category_id                  IN  NUMBER     DEFAULT NULL               -- ER(9158529)
         , p_lpn_from                     IN  VARCHAR2   DEFAULT NULL
         , p_lpn_from_id                  IN  NUMBER     DEFAULT NULL
         , p_lpn_to                       IN  VARCHAR2   DEFAULT NULL
         , p_lpn_to_id                    IN  NUMBER     DEFAULT NULL
         , p_lot_from                     IN  VARCHAR2   DEFAULT NULL
         , p_lot_to                       IN  VARCHAR2   DEFAULT NULL
         , p_supplier_lot_from            IN  VARCHAR2   DEFAULT NULL               -- Bug 8396954
         , p_supplier_lot_to              IN  VARCHAR2   DEFAULT NULL               -- Bug 8396954
         , p_serial_from                  IN  VARCHAR2   DEFAULT NULL
         , p_serial_to                    IN  VARCHAR2   DEFAULT NULL
         , p_workbench_vb                 IN  NUMBER     DEFAULT NULL
         , p_prepacked                    IN  VARCHAR2   DEFAULT NULL
         , p_project_id                   IN  NUMBER     DEFAULT NULL
         , p_task_id                      IN  NUMBER     DEFAULT NULL
         , p_unit_number                  IN  NUMBER     DEFAULT NULL
         , p_planning_org                 IN  VARCHAR2   DEFAULT NULL
         , p_owning_org                   IN  VARCHAR2   DEFAULT NULL
         , p_po_header_id                 IN  NUMBER     DEFAULT NULL
         , p_po_release_id                IN  NUMBER     DEFAULT NULL
         , p_shipment_header_id_asn       IN  NUMBER     DEFAULT NULL
         , p_shipment_header_id_interorg  IN  NUMBER     DEFAULT NULL
         , p_req_header_id                IN  NUMBER     DEFAULT NULL
         , p_vendor_id                    IN  NUMBER     DEFAULT NULL
         , p_vendor_site_id               IN  NUMBER     DEFAULT NULL
         , p_source_org_id                IN  NUMBER     DEFAULT NULL
         , p_chk_inbound                  IN  NUMBER     DEFAULT NULL
         , p_chk_receiving                IN  NUMBER     DEFAULT NULL
         , p_chk_onhand                   IN  NUMBER     DEFAULT NULL
         , p_include_po_without_asn       IN  NUMBER     DEFAULT NULL
         , p_expected_from_date           IN  DATE       DEFAULT NULL
         , p_expected_to_date             IN  DATE       DEFAULT NULL
         , p_internal_order_id            IN  NUMBER     DEFAULT NULL
         , p_vendor_item                  IN  VARCHAR2   DEFAULT NULL
         , p_grade_from                   IN  VARCHAR2   DEFAULT NULL
         , p_planning_query_mode          IN  NUMBER     DEFAULT NULL
         , p_owning_query_mode            IN  NUMBER     DEFAULT NULL
         , p_wms_enabled_flag             IN  NUMBER     DEFAULT NULL
         , p_subinventory_type            IN  NUMBER     DEFAULT NULL
         , p_rcv_query_mode               IN  NUMBER     DEFAULT NULL
         , p_detailed                     IN  NUMBER     DEFAULT 0
         , p_item_description             IN  VARCHAR2   DEFAULT NULL
         , p_qty_from                     IN  NUMBER     DEFAULT NULL
         , p_qty_to                       IN  NUMBER     DEFAULT NULL
         , p_view_by                      IN  VARCHAR2   DEFAULT NULL
         , p_locator_control_code         IN  NUMBER     DEFAULT NULL
         , p_wms_installed_flag           IN  NUMBER     DEFAULT NULL
         , p_check                        IN  NUMBER     DEFAULT NULL
	 , p_serial_attr_query		  IN  VARCHAR2   DEFAULT NULL		--  Bug 6429880
         , p_lot_attr_query               IN  VARCHAR2   DEFAULT NULL           --  Bug 7566588
         , p_responsibility_id            IN  NUMBER     DEFAULT NULL
         , p_resp_application_id          IN  NUMBER     DEFAULT NULL
         , p_is_projects_enabled_org      IN  NUMBER     DEFAULT 0
         ,p_expired_lots                  IN  VARCHAR2   DEFAULT NULL
         ,p_expiration_date               IN  DATE       DEFAULT NULL
	 , p_parent_lot			  IN  VARCHAR2	 DEFAULT NULL		-- BUG 7556505
	 ,p_shipment_header_id            IN  NUMBER     DEFAULT NULL     -- Bug 6633612
         );

   PROCEDURE SET_TREE_GLOBALS(
           p_tree_organization_id      IN NUMBER   DEFAULT NULL
         , p_view_by                   IN VARCHAR2 DEFAULT NULL
         , p_tree_subinventory_code    IN VARCHAR2 DEFAULT NULL
         , p_tree_loc_id               IN NUMBER   DEFAULT NULL
         , p_tree_item_id              IN NUMBER   DEFAULT NULL
         , p_tree_plpn_id              IN NUMBER   DEFAULT NULL
         , p_tree_mat_loc_id           IN NUMBER   DEFAULT NULL
         , p_tree_doc_type_id          IN NUMBER   DEFAULT NULL
         , p_tree_doc_num              IN VARCHAR2 DEFAULT NULL
         , p_tree_doc_header_id        IN NUMBER   DEFAULT NULL
         , p_tree_st_id                IN NUMBER   DEFAULT NULL
         , p_tree_rev                  IN VARCHAR2 DEFAULT NULL
         , p_tree_cg_id                IN VARCHAR2 DEFAULT NULL
         , p_tree_grade                IN VARCHAR2 DEFAULT NULL
 	      , p_tree_lot		       IN VARCHAR2 DEFAULT NULL
         , p_tree_serial               IN VARCHAR2 DEFAULT NULL
         , p_tree_node_type            IN VARCHAR2 DEFAULT NULL
         , p_tree_node_value           IN VARCHAR2 DEFAULT NULL
         , p_tree_node_state           IN NUMBER   DEFAULT NULL
         , p_tree_node_high_value      IN NUMBER   DEFAULT NULL
         , p_tree_node_low_value       IN NUMBER   DEFAULT NULL
	 , p_tree_serial_attr_query    IN VARCHAR2 DEFAULT NULL		-- Bug 6429880
         , p_tree_lot_attr_query       IN VARCHAR2 DEFAULT NULL         -- Bug 7566588
         , p_tree_event                IN VARCHAR2 DEFAULT NULL
         , p_tree_attribute_qf_lot     IN VARCHAR2 DEFAULT NULL
         , p_attribute_qf_serial       IN VARCHAR2 DEFAULT NULL
         , p_query_lot_attr            IN VARCHAR2 DEFAULT NULL
         , p_query_serial_attr         IN VARCHAR2 DEFAULT NULL
  	      , p_is_containerized          IN NUMBER   DEFAULT NULL
         );

   PROCEDURE EVENT (
            x_node_value IN OUT NOCOPY NUMBER
          , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
          , x_tbl_index  IN OUT NOCOPY NUMBER
          );

   FUNCTION GET_LAST_QUERY RETURN LONG;

END INV_MWB_CONTROLLER;

/
