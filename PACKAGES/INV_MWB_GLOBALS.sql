--------------------------------------------------------
--  DDL for Package INV_MWB_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: INVMWGLS.pls 120.16.12010000.5 2009/11/30 14:43:26 ksaripal ship $ */

 /*
  *  Query Find Parameters
  */

  /* Newly added columns*/
   g_organization_code           VARCHAR2(3);
   g_locator_name                VARCHAR2(200);
   g_item_name                   VARCHAR2(300);
   g_cost_group                  VARCHAR2(100);
   g_project_number              VARCHAR2(25);
   g_task_number                 VARCHAR2(25);
   g_owning_party                VARCHAR2(300);
   g_planning_party              VARCHAR2(300);
   g_lpn_state                   VARCHAR2(30);
   g_status                      VARCHAR2(300);
/* Newly added columns end*/

   g_serial_attr_query		 VARCHAR2(300);				--	Bug 6429880
   g_lot_attr_query              VARCHAR2(300);                         --      Bug 7566588

   g_last_query                  LONG;

   g_organization_id             NUMBER;
   g_locator_id                  NUMBER;
   g_subinventory_code           VARCHAR2(30);
   g_client_code                 VARCHAR2(25);              -- ER(9158529 client)
   g_inventory_item_id           NUMBER;
   g_revision                    VARCHAR2(3);
   g_status_id                   NUMBER;
   g_cost_group_id               NUMBER;
   g_category_set_id             NUMBER;                    -- ER(9158529)
   g_category_id                 NUMBER;                    -- ER(9158529)
   g_lpn_from                    VARCHAR2(30);
   g_lpn_to                      VARCHAR2(30);
   g_lpn_from_id                 NUMBER;
   g_lpn_to_id                   NUMBER;
   g_lot_from                    VARCHAR2(80);
   g_lot_to                      VARCHAR2(80);
   g_supplier_lot_from           VARCHAR2(80);               -- Bug 8396954
   g_supplier_lot_to             VARCHAR2(80);               -- Bug 8396954
   g_serial_from                 VARCHAR2(30);
   g_serial_to                   VARCHAR2(30);
   g_workbench_vb                NUMBER;
   g_prepacked                   VARCHAR2(30);
   g_project_id                  NUMBER;
   g_task_id                     NUMBER;
   g_unit_number                 VARCHAR2(30);
   g_planning_org                VARCHAR2(30);
   g_owning_org                  VARCHAR2(30);
   g_po_header_id                NUMBER;
   g_po_release_id               NUMBER;
   g_shipment_header_id_asn      VARCHAR2(30);
   g_shipment_header_id_interorg VARCHAR2(30);
   g_req_header_id               NUMBER;
   g_vendor_id                   NUMBER;
   g_vendor_site_id              NUMBER;
   g_source_org_id               NUMBER;
   g_chk_inbound                 NUMBER;
   g_chk_receiving               NUMBER;
   g_chk_onhand                  NUMBER;
   g_include_po_without_asn      NUMBER;
   g_expected_from_date          DATE;
   g_expected_to_date            DATE;
   g_internal_order_id           NUMBER;
   g_vendor_item                 VARCHAR2(250);
   g_grade_from_code             VARCHAR2(150);
   g_planning_query_mode         NUMBER;
   g_owning_qry_mode             NUMBER;
   g_wms_enabled_flag            NUMBER;
   g_sub_type                    NUMBER;
   g_rcv_query_mode              NUMBER;
   g_detailed                    NUMBER;
   g_item_description            VARCHAR2(240);
   g_qty_from                    NUMBER;
   g_qty_to                      NUMBER;
   g_locator_control_code        NUMBER;
   g_wms_installed_flag          NUMBER;
   g_check                       NUMBER;
   g_responsibility_id           NUMBER;
   g_resp_application_id         NUMBER;
   g_mln_context_code            VARCHAR2(30);
   g_msn_context_code            VARCHAR2(30);
   g_grade_controlled            NUMBER;
   g_serial_controlled           NUMBER;
   g_lot_controlled              NUMBER;
   g_only_locator_status         NUMBER;
   g_only_subinventory_status    NUMBER;
   g_containerized               NUMBER;
   g_locator_controlled          NUMBER;
   g_inserted_under_org          VARCHAR2(10);
   g_revision_controlled         NUMBER;
   g_only_lot_status             NUMBER;
   g_only_serial_status          NUMBER;
   g_view_by                     VARCHAR2(30);
   g_multiple_loc_selected       VARCHAR2(30);
   g_tree_organization_id        NUMBER;
   g_tree_loc_id                 NUMBER;
   g_tree_item_id                NUMBER;
   g_tree_subinventory_code      VARCHAR2(30);
   g_tree_parent_lpn_id          NUMBER;
   g_tree_mat_loc_id             NUMBER;
   g_tree_doc_type_id            NUMBER;
   g_tree_doc_num                VARCHAR2(30);
   g_tree_doc_header_id          NUMBER;
   g_tree_st_id                  NUMBER;
   g_tree_rev                    VARCHAR2(3);
   g_tree_cg_id                  NUMBER;
   g_tree_grade_code             VARCHAR2(150);
   g_tree_serial_number          VARCHAR2(30);
   g_tree_lot_number             VARCHAR2(80);
   g_tree_node_type              VARCHAR2(50);
   g_tree_node_value             VARCHAR2(300);
   g_tree_node_state             NUMBER;
   g_tree_node_high_value        NUMBER;
   g_tree_node_low_value         NUMBER;
   g_tree_serial_attr_query      VARCHAR2(300);
   g_tree_attribute_qf_lot       VARCHAR2(300);
   g_tree_attribute_qf_serial    VARCHAR2(300);
   g_tree_query_lot_attr         VARCHAR2(300);
   g_tree_query_serial_attr      VARCHAR2(300);
   g_tree_lot_attr_query         VARCHAR2(300);
   g_tree_event                  VARCHAR2(50);
   g_lot_context                 VARCHAR2(30);
   g_serial_context              VARCHAR2(30);
   g_is_projects_enabled_org     NUMBER;
   g_is_nested_lpn               VARCHAR2(10) := 'NO';

    --KMOTUPAL ME # 3922793
   g_expired_lots                VARCHAR2(1);
   g_expiration_date             DATE;
   g_shipment_header_id		 NUMBER; -- BUG 6633612
   g_parent_lot			 VARCHAR2(80);			-- BUG 7556505

   PROCEDURE print_parameters;
   PROCEDURE dump_parameters;

   PROCEDURE print_msg(
             p_package   IN VARCHAR2
           , p_procedure IN VARCHAR2
           , p_msg       IN VARCHAR2
           );

   SUBTYPE very_long_str IS VARCHAR2(30000);
   SUBTYPE long_str      IS VARCHAR2(5000);
   SUBTYPE short_str     IS VARCHAR2(1000);

END inv_mwb_globals;

/
