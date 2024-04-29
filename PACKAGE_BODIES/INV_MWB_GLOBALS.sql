--------------------------------------------------------
--  DDL for Package Body INV_MWB_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_GLOBALS" AS
/* $Header: INVMWGLB.pls 120.14.12010000.5 2009/11/30 14:44:27 ksaripal ship $ */

   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_GLOBALS';

   PROCEDURE mdebug(msg IN VARCHAR2) IS
   BEGIN
      INV_TRX_UTIL_PUB.TRACE( msg, g_pkg_name, 4 );
   END mdebug;


   PROCEDURE print_parameters IS
   BEGIN

      mdebug(' g_organization_id              = '||  g_organization_id            );
      mdebug(' g_organization_code            = '||  g_organization_code          );
      mdebug(' g_locator_id                   = '||  g_locator_id                 );
      mdebug(' g_locator_name                 = '||  g_locator_name               );
      mdebug(' g_subinventory_code            = '||  g_subinventory_code          );
      mdebug(' g_client_code                  = '||  g_client_code                );        -- ER(9158529 client)
      mdebug(' g_inventory_item_id            = '||  g_inventory_item_id          );
      mdebug(' g_item_name                    = '||  g_item_name                  );
      mdebug(' g_item_description             = '||  g_item_description           );

      mdebug(' g_revision                     = '||  g_revision                   );
      mdebug(' g_status_id                    = '||  g_status_id                  );
      mdebug(' g_cost_group_id                = '||  g_cost_group_id              );
      mdebug(' g_cost_group                   = '||  g_cost_group                 );
      mdebug(' g_category_set_id              = '||  g_category_set_id            );        -- ER(9158529)
      mdebug(' g_category_id                  = '||  g_category_id                );        -- ER(9158529)
      mdebug(' g_lpn_from                     = '||  g_lpn_from                   );
      mdebug(' g_lpn_to                       = '||  g_lpn_to                     );
      mdebug(' g_lpn_from_id                  = '||  g_lpn_from_id                );
      mdebug(' g_lpn_to_id                    = '||  g_lpn_to_id                  );
      mdebug(' g_lot_from                     = '||  g_lot_from                   );
      mdebug(' g_lot_to                       = '||  g_lot_to                     );
      mdebug(' g_supplier_lot_from            = '||  g_supplier_lot_from          );        -- Bug 8396954
      mdebug(' g_supplier_lot_to              = '||  g_supplier_lot_to            );        -- Bug 8396954
      mdebug(' g_serial_from                  = '||  g_serial_from                );
      mdebug(' g_serial_to                    = '||  g_serial_to                  );
      mdebug(' g_workbench_vb                 = '||  g_workbench_vb               );
      mdebug(' g_prepacked                    = '||  g_prepacked                  );
      mdebug(' g_lpn_state                    = '||  g_lpn_state                  );
      mdebug(' g_project_id                   = '||  g_project_id                 );
      mdebug(' g_project_number               = '||  g_project_number             );
      mdebug(' g_task_id                      = '||  g_task_id                    );
      mdebug(' g_task_number                  = '||  g_task_number                );
      mdebug(' g_unit_number                  = '||  g_unit_number                );
      mdebug(' g_owning_party                 = '||  g_owning_party               );
      mdebug(' g_planning_party               = '||  g_planning_party             );
      mdebug(' g_planning_org                 = '||  g_planning_org               );
      mdebug(' g_owning_org                   = '||  g_owning_org                 );
      mdebug(' g_po_header_id                 = '||  g_po_header_id               );
      mdebug(' g_po_release_id                = '||  g_po_release_id              );
      mdebug(' g_shipment_header_id_asn       = '||  g_shipment_header_id_asn     );
      mdebug(' g_shipment_header_id_interorg  = '||  g_shipment_header_id_interorg);
      mdebug(' g_req_header_id                = '||  g_req_header_id              );
      mdebug(' g_vendor_id                    = '||  g_vendor_id                  );
      mdebug(' g_vendor_site_id               = '||  g_vendor_site_id             );
      mdebug(' g_source_org_id                = '||  g_source_org_id              );
      mdebug(' g_chk_inbound                  = '||  g_chk_inbound                );
      mdebug(' g_chk_receiving                = '||  g_chk_receiving              );
      mdebug(' g_chk_onhand                   = '||  g_chk_onhand                 );
      mdebug(' g_include_po_without_asn       = '||  g_include_po_without_asn     );
      mdebug(' g_expected_from_date           = '||  g_expected_from_date         );
      mdebug(' g_expected_to_date             = '||  g_expected_to_date           );
      mdebug(' g_internal_order_id            = '||  g_internal_order_id          );
      mdebug(' g_vendor_item                  = '||  g_vendor_item                );
      mdebug(' g_grade_from_code              = '||  g_grade_from_code            );
      mdebug(' g_planning_query_mode          = '||  g_planning_query_mode        );
      mdebug(' g_owning_qry_mode              = '||  g_owning_qry_mode            );
      mdebug(' g_wms_enabled_flag             = '||  g_wms_enabled_flag           );
      mdebug(' g_sub_type                     = '||  g_sub_type                   );
      mdebug(' g_rcv_query_mode               = '||  g_rcv_query_mode             );
      mdebug(' g_detailed                     = '||  g_detailed                   );
      mdebug(' g_qty_from                     = '||  g_qty_from                   );
      mdebug(' g_qty_to                       = '||  g_qty_to                     );
      mdebug(' g_locator_control_code         = '||  g_locator_control_code       );
      mdebug(' g_wms_installed_flag           = '||  g_wms_installed_flag         );
      mdebug(' g_check                        = '||  g_check                      );
      mdebug(' g_serial_attr_query            = '||  g_serial_attr_query          );		-- Bug 6429880
      mdebug(' g_lot_attr_query               = '||  g_lot_attr_query             );            -- Bug 7566588
      mdebug(' g_responsibility_id            = '||  g_responsibility_id          );
      mdebug(' g_resp_application_id          = '||  g_resp_application_id        );
      mdebug(' g_mln_context_code             = '||  g_mln_context_code           );
      mdebug(' g_msn_context_code             = '||  g_msn_context_code           );
      mdebug(' g_grade_controlled             = '||  g_grade_controlled           );
      mdebug(' g_serial_controlled            = '||  g_serial_controlled          );
      mdebug(' g_lot_controlled               = '||  g_lot_controlled             );
      mdebug(' g_only_locator_status          = '||  g_only_locator_status        );
      mdebug(' g_only_subinventory_status     = '||  g_only_subinventory_status   );
      mdebug(' g_containerized                = '||  g_containerized              );
      mdebug(' g_locator_controlled           = '||  g_locator_controlled         );
      mdebug(' g_inserted_under_org           = '||  g_inserted_under_org         );
      mdebug(' g_revision_controlled          = '||  g_revision_controlled        );
      mdebug(' g_only_lot_status              = '||  g_only_lot_status            );
      mdebug(' g_only_serial_status           = '||  g_only_serial_status         );
      mdebug(' g_view_by                      = '||  g_view_by                    );
      mdebug(' g_status                       = '||  g_status                     );
      mdebug(' g_tree_organization_id         = '||  g_tree_organization_id       );
      mdebug(' g_tree_loc_id                  = '||  g_tree_loc_id                );
      mdebug(' g_tree_item_id                 = '||  g_tree_item_id               );
      mdebug(' g_tree_subinventory_code       = '||  g_tree_subinventory_code     );
      mdebug(' g_tree_parent_lpn_id           = '||  g_tree_parent_lpn_id         );
      mdebug(' g_tree_mat_loc_id              = '||  g_tree_mat_loc_id            );
      mdebug(' g_tree_doc_type_id             = '||  g_tree_doc_type_id           );
      mdebug(' g_tree_doc_num                 = '||  g_tree_doc_num               );
      mdebug(' g_tree_doc_header_id           = '||  g_tree_doc_header_id         );
      mdebug(' g_tree_st_id                   = '||  g_tree_st_id                 );
      mdebug(' g_tree_rev                     = '||  g_tree_rev                   );
      mdebug(' g_tree_cg_id                   = '||  g_tree_cg_id                 );
      mdebug(' g_tree_grade_code              = '||  g_tree_grade_code            );
      mdebug(' g_tree_serial_number           = '||  g_tree_serial_number         );
      mdebug(' g_tree_lot_number              = '||  g_tree_lot_number            );
      mdebug(' g_tree_node_type               = '||  g_tree_node_type             );
      mdebug(' g_tree_node_value              = '||  g_tree_node_value            );
      mdebug(' g_tree_node_state              = '||  g_tree_node_state            );
      mdebug(' g_tree_node_high_value         = '||  g_tree_node_high_value       );
      mdebug(' g_tree_node_low_value          = '||  g_tree_node_low_value        );
      mdebug(' g_tree_serial_attr_query       = '||  g_tree_serial_attr_query     );
      mdebug(' g_tree_attribute_qf_lot        = '||  g_tree_attribute_qf_lot      );
      mdebug(' g_tree_attribute_qf_serial     = '||  g_tree_attribute_qf_serial   );
      mdebug(' g_tree_query_lot_attr          = '||  g_tree_query_lot_attr        );
      mdebug(' g_tree_query_serial_attr       = '||  g_tree_query_serial_attr     );
      mdebug(' g_tree_lot_attr_query          = '||  g_tree_lot_attr_query        );
      mdebug(' g_tree_event                   = '||  g_tree_event                 );
      mdebug(' g_lot_context                  = '||  g_lot_context                );
      mdebug(' g_serial_context               = '||  g_serial_context             );
      mdebug(' g_is_projects_enabled_org      = '||  g_is_projects_enabled_org    );
      mdebug(' g_multiple_loc_selected        = '||  g_multiple_loc_selected      );
    --KMOTUPAL ME # 3922793
      mdebug(' g_expired_lots                 = '||  g_expired_lots               );
      mdebug(' g_expiration_date              = '||  g_expiration_date            );
      mdebug(' g_parent_lot		      = '||  g_parent_lot		  );			-- BUG 7556505
      mdebug(' g_shipment_header_id           = '||  g_shipment_header_id         );      -- BUG 6633612

   END print_parameters;

   PROCEDURE print_msg(
             p_package   IN VARCHAR2
           , p_procedure IN VARCHAR2
           , p_msg       IN VARCHAR2
            ) IS
   BEGIN

      INV_TRX_UTIL_PUB.TRACE( p_msg, p_package||'.'||p_procedure, 4 );

   END print_msg;

   PROCEDURE dump_parameters IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      sql_stmt LONG;
   BEGIN
     null;

/*      sql_stmt := ' INSERT into inv_mwb_test_set(
          g_id
        , g_organization_code
        , g_locator_name
        , g_item_name
        , g_cost_group
        , g_project_number
        , g_task_number
        , g_owning_party
        , g_planning_party
        , g_lpn_state
        , g_status
        , g_last_query
        , g_organization_id
        , g_locator_id
        , g_subinventory_code
        , g_inventory_item_id
        , g_revision
        , g_status_id
        , g_cost_group_id
        , g_lpn_from
        , g_lpn_to
        , g_lpn_from_id
        , g_lpn_to_id
        , g_lot_from
        , g_lot_to
        , g_serial_from
        , g_serial_to
        , g_workbench_vb
        , g_prepacked
        , g_project_id
        , g_task_id
        , g_unit_number
        , g_planning_org
        , g_owning_org
        , g_po_header_id
        , g_po_release_id
        , g_shipment_header_id_asn
        , g_shipment_header_id_interorg
        , g_req_header_id
        , g_vendor_id
        , g_vendor_site_id
        , g_source_org_id
        , g_chk_inbound
        , g_chk_receiving
        , g_chk_onhand
        , g_include_po_without_asn
        , g_expected_from_date
        , g_expected_to_date
        , g_internal_order_id
        , g_vendor_item
        , g_grade_from_code
        , g_planning_query_mode
        , g_owning_qry_mode
        , g_wms_enabled_flag
        , g_sub_type
        , g_rcv_query_mode
        , g_detailed
        , g_item_description
        , g_qty_from
        , g_qty_to
        , g_locator_control_code
        , g_wms_installed_flag
        , g_check
        , g_responsibility_id
        , g_resp_application_id
        , g_mln_context_code
        , g_msn_context_code
        , g_grade_controlled
        , g_serial_controlled
        , g_lot_controlled
        , g_only_locator_status
        , g_only_subinventory_status
        , g_containerized
        , g_locator_controlled
        , g_inserted_under_org
        , g_revision_controlled
        , g_only_lot_status
        , g_only_serial_status
        , g_view_by
        , g_multiple_loc_selected
        , g_tree_organization_id
        , g_tree_loc_id
        , g_tree_item_id
        , g_tree_subinventory_code
        , g_tree_parent_lpn_id
        , g_tree_mat_loc_id
        , g_tree_doc_type_id
        , g_tree_doc_num
        , g_tree_doc_header_id
        , g_tree_st_id
        , g_tree_rev
        , g_tree_cg_id
        , g_tree_grade_code
        , g_tree_serial_number
        , g_tree_lot_number
        , g_tree_node_type
        , g_tree_node_value
        , g_tree_node_state
        , g_tree_node_high_value
        , g_tree_node_low_value
        , g_tree_serial_attr_query
        , g_tree_attribute_qf_lot
        , g_tree_attribute_qf_serial
        , g_tree_query_lot_attr
        , g_tree_query_serial_attr
        , g_tree_lot_attr_query
        , g_tree_event
        , g_lot_context
        , g_serial_context
        , g_is_projects_enabled_org
        , g_is_nested_lpn
      ) VALUES (
         inv_mwb_test_set_s.NEXTVAL
         :g_organization_code
         :g_locator_name
         :g_item_name
         :g_cost_group
         :g_project_number
         :g_task_number
         :g_owning_party
         :g_planning_party
         :g_lpn_state
         :g_status
         :g_last_query
         :g_organization_id
         :g_locator_id
         :g_subinventory_code
         :g_inventory_item_id
         :g_revision
         :g_status_id
         :g_cost_group_id
         :g_lpn_from
         :g_lpn_to
         :g_lpn_from_id
         :g_lpn_to_id
         :g_lot_from
         :g_lot_to
         :g_serial_from
         :g_serial_to
         :g_workbench_vb
         :g_prepacked
         :g_project_id
         :g_task_id
         :g_unit_number
         :g_planning_org
         :g_owning_org
         :g_po_header_id
         :g_po_release_id
         :g_shipment_header_id_asn
         :g_shipment_header_id_interorg
         :g_req_header_id
         :g_vendor_id
         :g_vendor_site_id
         :g_source_org_id
         :g_chk_inbound
         :g_chk_receiving
         :g_chk_onhand
         :g_include_po_without_asn
         :g_expected_from_date
         :g_expected_to_date
         :g_internal_order_id
         :g_vendor_item
         :g_grade_from_code
         :g_planning_query_mode
         :g_owning_qry_mode
         :g_wms_enabled_flag
         :g_sub_type
         :g_rcv_query_mode
         :g_detailed
         :g_item_description
         :g_qty_from
         :g_qty_to
         :g_locator_control_code
         :g_wms_installed_flag
         :g_check
         :g_responsibility_id
         :g_resp_application_id
         :g_mln_context_code
         :g_msn_context_code
         :g_grade_controlled
         :g_serial_controlled
         :g_lot_controlled
         :g_only_locator_status
         :g_only_subinventory_status
         :g_containerized
         :g_locator_controlled
         :g_inserted_under_org
         :g_revision_controlled
         :g_only_lot_status
         :g_only_serial_status
         :g_view_by
         :g_multiple_loc_selected
         :g_tree_organization_id
         :g_tree_loc_id
         :g_tree_item_id
         :g_tree_subinventory_code
         :g_tree_parent_lpn_id
         :g_tree_mat_loc_id
         :g_tree_doc_type_id
         :g_tree_doc_num
         :g_tree_doc_header_id
         :g_tree_st_id
         :g_tree_rev
         :g_tree_cg_id
         :g_tree_grade_code
         :g_tree_serial_number
         :g_tree_lot_number
         :g_tree_node_type
         :g_tree_node_value
         :g_tree_node_state
         :g_tree_node_high_value
         :g_tree_node_low_value
         :g_tree_serial_attr_query
         :g_tree_attribute_qf_lot
         :g_tree_attribute_qf_serial
         :g_tree_query_lot_attr
         :g_tree_query_serial_attr
         :g_tree_lot_attr_query
         :g_tree_event
         :g_lot_context
         :g_serial_context
         :g_is_projects_enabled_org
         :g_is_nested_lpn
      ) ';



      EXECUTE IMMEDIATE sql_stmt USING
           g_organization_code
         , g_locator_name
         , g_item_name
         , g_cost_group
         , g_project_number
         , g_task_number
         , g_owning_party
         , g_planning_party
         , g_lpn_state
         , g_status
         , g_last_query
         , g_organization_id
         , g_locator_id
         , g_subinventory_code
         , g_inventory_item_id
         , g_revision
         , g_status_id
         , g_cost_group_id
         , g_lpn_from
         , g_lpn_to
         , g_lpn_from_id
         , g_lpn_to_id
         , g_lot_from
         , g_lot_to
         , g_serial_from
         , g_serial_to
         , g_workbench_vb
         , g_prepacked
         , g_project_id
         , g_task_id
         , g_unit_number
         , g_planning_org
         , g_owning_org
         , g_po_header_id
         , g_po_release_id
         , g_shipment_header_id_asn
         , g_shipment_header_id_interorg
         , g_req_header_id
         , g_vendor_id
         , g_vendor_site_id
         , g_source_org_id
         , g_chk_inbound
         , g_chk_receiving
         , g_chk_onhand
         , g_include_po_without_asn
         , g_expected_from_date
         , g_expected_to_date
         , g_internal_order_id
         , g_vendor_item
         , g_grade_from_code
         , g_planning_query_mode
         , g_owning_qry_mode
         , g_wms_enabled_flag
         , g_sub_type
         , g_rcv_query_mode
         , g_detailed
         , g_item_description
         , g_qty_from
         , g_qty_to
         , g_locator_control_code
         , g_wms_installed_flag
         , g_check
         , g_responsibility_id
         , g_resp_application_id
         , g_mln_context_code
         , g_msn_context_code
         , g_grade_controlled
         , g_serial_controlled
         , g_lot_controlled
         , g_only_locator_status
         , g_only_subinventory_status
         , g_containerized
         , g_locator_controlled
         , g_inserted_under_org
         , g_revision_controlled
         , g_only_lot_status
         , g_only_serial_status
         , g_view_by
         , g_multiple_loc_selected
         , g_tree_organization_id
         , g_tree_loc_id
         , g_tree_item_id
         , g_tree_subinventory_code
         , g_tree_parent_lpn_id
         , g_tree_mat_loc_id
         , g_tree_doc_type_id
         , g_tree_doc_num
         , g_tree_doc_header_id
         , g_tree_st_id
         , g_tree_rev
         , g_tree_cg_id
         , g_tree_grade_code
         , g_tree_serial_number
         , g_tree_lot_number
         , g_tree_node_type
         , g_tree_node_value
         , g_tree_node_state
         , g_tree_node_high_value
         , g_tree_node_low_value
         , g_tree_serial_attr_query
         , g_tree_attribute_qf_lot
         , g_tree_attribute_qf_serial
         , g_tree_query_lot_attr
         , g_tree_query_serial_attr
         , g_tree_lot_attr_query
         , g_tree_event
         , g_lot_context
         , g_serial_context
         , g_is_projects_enabled_org
         , g_is_nested_lpn;
*/

/*   INSERT INTO inv_mwb_test_set (
   g_id                          ,
   g_organization_code           ,
   g_locator_name                ,
   g_item_name                   ,
   g_cost_group                  ,
   g_project_number              ,
   g_task_number                 ,
   g_owning_party                ,
   g_planning_party              ,
   g_lpn_state                   ,
   g_status                      ,
   g_last_query                  ,
   g_organization_id             ,
   g_locator_id                  ,
   g_subinventory_code           ,
   g_inventory_item_id           ,
   g_revision                    ,
   g_status_id                   ,
   g_cost_group_id               ,
   g_lpn_from                    ,
   g_lpn_to                      ,
   g_lpn_from_id                 ,
   g_lpn_to_id                   ,
   g_lot_from                    ,
   g_lot_to                      ,
   g_serial_from                 ,
   g_serial_to                   ,
   g_workbench_vb                ,
   g_prepacked                   ,
   g_project_id                  ,
   g_task_id                     ,
   g_unit_number                 ,
   g_planning_org                ,
   g_owning_org                  ,
   g_po_header_id                ,
   g_po_release_id               ,
   g_shipment_header_id_asn      ,
   g_shipment_header_id_interorg ,
   g_req_header_id               ,
   g_vendor_id                   ,
   g_vendor_site_id              ,
   g_source_org_id               ,
   g_chk_inbound                 ,
   g_chk_receiving               ,
   g_chk_onhand                  ,
   g_include_po_without_asn      ,
   g_expected_from_date          ,
   g_expected_to_date            ,
   g_internal_order_id           ,
   g_vendor_item                 ,
   g_grade_from_code             ,
   g_planning_query_mode         ,
   g_owning_qry_mode             ,
   g_wms_enabled_flag            ,
   g_sub_type                    ,
   g_rcv_query_mode              ,
   g_detailed                    ,
   g_item_description            ,
   g_qty_from                    ,
   g_qty_to                      ,
   g_locator_control_code        ,
   g_wms_installed_flag          ,
   g_check                       ,
   g_responsibility_id           ,
   g_resp_application_id         ,
   g_mln_context_code            ,
   g_msn_context_code            ,
   g_grade_controlled            ,
   g_serial_controlled           ,
   g_lot_controlled              ,
   g_only_locator_status         ,
   g_only_subinventory_status    ,
   g_containerized               ,
   g_locator_controlled          ,
   g_inserted_under_org          ,
   g_revision_controlled         ,
   g_only_lot_status             ,
   g_only_serial_status          ,
   g_view_by                     ,
   g_multiple_loc_selected       ,
   g_tree_organization_id        ,
   g_tree_loc_id                 ,
   g_tree_item_id                ,
   g_tree_subinventory_code      ,
   g_tree_parent_lpn_id          ,
   g_tree_mat_loc_id             ,
   g_tree_doc_type_id            ,
   g_tree_doc_num                ,
   g_tree_doc_header_id          ,
   g_tree_st_id                  ,
   g_tree_rev                    ,
   g_tree_cg_id                  ,
   g_tree_grade_code             ,
   g_tree_serial_number          ,
   g_tree_lot_number             ,
   g_tree_node_type              ,
   g_tree_node_value             ,
   g_tree_node_state             ,
   g_tree_node_high_value        ,
   g_tree_node_low_value         ,
   g_tree_serial_attr_query      ,
   g_tree_attribute_qf_lot       ,
   g_tree_attribute_qf_serial    ,
   g_tree_query_lot_attr         ,
   g_tree_query_serial_attr      ,
   g_tree_lot_attr_query         ,
   g_tree_event                  ,
   g_lot_context                 ,
   g_serial_context              ,
   g_is_projects_enabled_org     ,
   g_is_nested_lpn
   )
   VALUES (
   inv_mwb_test_set_s.nextval    ,
   g_organization_code           ,
   g_locator_name                ,
   g_item_name                   ,
   g_cost_group                  ,
   g_project_number              ,
   g_task_number                 ,
   g_owning_party                ,
   g_planning_party              ,
   g_lpn_state                   ,
   g_status                      ,
   g_last_query                  ,
   g_organization_id             ,
   g_locator_id                  ,
   g_subinventory_code           ,
   g_inventory_item_id           ,
   g_revision                    ,
   g_status_id                   ,
   g_cost_group_id               ,
   g_lpn_from                    ,
   g_lpn_to                      ,
   g_lpn_from_id                 ,
   g_lpn_to_id                   ,
   g_lot_from                    ,
   g_lot_to                      ,
   g_serial_from                 ,
   g_serial_to                   ,
   g_workbench_vb                ,
   g_prepacked                   ,
   g_project_id                  ,
   g_task_id                     ,
   g_unit_number                 ,
   g_planning_org                ,
   g_owning_org                  ,
   g_po_header_id                ,
   g_po_release_id               ,
   g_shipment_header_id_asn      ,
   g_shipment_header_id_interorg ,
   g_req_header_id               ,
   g_vendor_id                   ,
   g_vendor_site_id              ,
   g_source_org_id               ,
   g_chk_inbound                 ,
   g_chk_receiving               ,
   g_chk_onhand                  ,
   g_include_po_without_asn      ,
   g_expected_from_date          ,
   g_expected_to_date            ,
   g_internal_order_id           ,
   g_vendor_item                 ,
   g_grade_from_code             ,
   g_planning_query_mode         ,
   g_owning_qry_mode             ,
   g_wms_enabled_flag            ,
   g_sub_type                    ,
   g_rcv_query_mode              ,
   g_detailed                    ,
   g_item_description            ,
   g_qty_from                    ,
   g_qty_to                      ,
   g_locator_control_code        ,
   g_wms_installed_flag          ,
   g_check                       ,
   g_responsibility_id           ,
   g_resp_application_id         ,
   g_mln_context_code            ,
   g_msn_context_code            ,
   g_grade_controlled            ,
   g_serial_controlled           ,
   g_lot_controlled              ,
   g_only_locator_status         ,
   g_only_subinventory_status    ,
   g_containerized               ,
   g_locator_controlled          ,
   g_inserted_under_org          ,
   g_revision_controlled         ,
   g_only_lot_status             ,
   g_only_serial_status          ,
   g_view_by                     ,
   g_multiple_loc_selected       ,
   g_tree_organization_id        ,
   g_tree_loc_id                 ,
   g_tree_item_id                ,
   g_tree_subinventory_code      ,
   g_tree_parent_lpn_id          ,
   g_tree_mat_loc_id             ,
   g_tree_doc_type_id            ,
   g_tree_doc_num                ,
   g_tree_doc_header_id          ,
   g_tree_st_id                  ,
   g_tree_rev                    ,
   g_tree_cg_id                  ,
   g_tree_grade_code             ,
   g_tree_serial_number          ,
   g_tree_lot_number             ,
   g_tree_node_type              ,
   g_tree_node_value             ,
   g_tree_node_state             ,
   g_tree_node_high_value        ,
   g_tree_node_low_value         ,
   g_tree_serial_attr_query      ,
   g_tree_attribute_qf_lot       ,
   g_tree_attribute_qf_serial    ,
   g_tree_query_lot_attr         ,
   g_tree_query_serial_attr      ,
   g_tree_lot_attr_query         ,
   g_tree_event                  ,
   g_lot_context                 ,
   g_serial_context              ,
   g_is_projects_enabled_org     ,
   g_is_nested_lpn
   );


         COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
--null;
*/
END dump_parameters;

end inv_mwb_globals;

/
