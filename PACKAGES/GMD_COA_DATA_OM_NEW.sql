--------------------------------------------------------
--  DDL for Package GMD_COA_DATA_OM_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_COA_DATA_OM_NEW" AUTHID CURRENT_USER AS
/* $Header: GMDGCOAS.pls 120.4.12000000.1 2007/01/16 18:13:04 appldev ship $ */
/*  API name: GMD_COA_DATA_OM_NEW
 *  Type:  Group
 *  Function:   gather COA data
 **/

    -- global variables
   g_gmdlog_location  VARCHAR2(255) := NULL;

  TYPE t_coa_hdr_rec IS RECORD
       (gmd_coa_id      BINARY_INTEGER,
        order_id        oe_order_headers.header_id%TYPE,
        line_id         oe_order_lines.line_id%TYPE,
        delivery_detail_id         wsh_delivery_details.delivery_detail_id%TYPE,
        --orgn_code       op_ordr_hdr.orgn_code%TYPE,        --INVCONV
        organization_id    mtl_parameters.organization_id%TYPE, --INVCONV
        organization_code  mtl_parameters.organization_code%TYPE, --INVCONV
        order_no        oe_order_headers.order_number%TYPE,
        custpo_no       oe_order_headers.cust_po_number%TYPE,
        shipdate        oe_order_lines.schedule_ship_date%TYPE,
        cust_id         hz_cust_accounts.cust_account_id%TYPE,
        cust_no         hz_cust_accounts.account_number%TYPE,
        cust_name       hz_parties.party_name%TYPE,
        bol_id          wsh_new_deliveries.delivery_id%TYPE,
        bol_no          wsh_new_deliveries.name%TYPE,
        --item_id         ic_item_mst.item_id%TYPE,  --INVCONV
        --item_no         ic_item_mst.item_no%TYPE, --INVCONV
        --item_desc       ic_item_mst.item_desc1%TYPE, --INVCONV
        inventory_item_id mtl_system_items_b_kfv.inventory_item_id%TYPE, --INVCONV
        item_number       mtl_system_items_b_kfv.concatenated_segments%TYPE, --INVCONV
        item_description  mtl_system_items_b_kfv.description%TYPE, --INVCONV
        revision            mtl_item_revisions.revision%TYPE,  --Bug# 4662469
        --whse_code       ic_whse_mst.whse_code%TYPE, --INVCONV
        --whse_name       ic_whse_mst.whse_name%TYPE, --INVCONV
        subinventory      mtl_secondary_inventories.secondary_inventory_name%TYPE, --INVCONV
        --lot_id          ic_lots_mst.lot_id%TYPE, --INVCONV
        --lot_no          ic_lots_mst.lot_no%TYPE, --INVCONV
        --lot_desc        ic_lots_mst.lot_desc%TYPE, --INVCONV
        --sublot_no       ic_lots_mst.sublot_no%TYPE, --INVCONV
        lot_number        mtl_lot_numbers.lot_number%TYPE, --INVCONV
        lot_description   mtl_lot_numbers.description%TYPE, --INVCONV
        order_qty1      oe_order_lines.ordered_quantity%TYPE,
        order_qty2      oe_order_lines.ordered_quantity2%TYPE,
        order_uom1       oe_order_lines.order_quantity_uom%TYPE,  --INVCONV
        order_uom2       oe_order_lines.ordered_quantity_UOM2%TYPE, --INVCONV
        ship_qty1       oe_order_lines.shipped_quantity%TYPE,
        ship_qty2       oe_order_lines.shipped_quantity2%TYPE,
    	ship_qty_uom1       oe_order_lines.shipping_quantity_uom%TYPE, --Bug # 3710191 added these two lines for the fields ship_uom1 and ship_uom2
        ship_qty_uom2       oe_order_lines.shipping_quantity_uom2%TYPE,  --INVCONV
        ship_from_org_id oe_order_lines.ship_from_org_id%TYPE,
        ship_to_site_id  oe_order_lines.ship_to_org_id%TYPE,   --Bug 4166529 added.
        org_id            oe_order_lines.org_id%TYPE,
        report_title    VARCHAR2(4),
	spec_hdr_text_code NUMBER(10) -- Bug # 4260445
       );

  TYPE t_coa_dtl_rec IS RECORD
      (gmd_coa_id      BINARY_INTEGER,
       result_id       gmd_results.result_id%TYPE,
       result_date     gmd_results.result_date%TYPE,
       spec_id         gmd_specifications_b.spec_id%TYPE,
       test_id         gmd_qc_tests_b.test_id%TYPE,
       test_code       gmd_qc_tests_b.test_code%TYPE,
       test_method     varchar2(80),
       test_type       gmd_qc_tests_b.test_type%TYPE,
       test_display    gmd_qc_tests.test_desc%TYPE,
       result          gmd_results.result_value_char%TYPE,
       specification   varchar2(200),
       min_spec        varchar2(240),
       max_spec        varchar2(240),
       mean            gmd_composite_results.mean%TYPE,
       mode_char       gmd_composite_results.mode_char%TYPE,
       test_unit       gmd_qc_tests_b.test_unit%TYPE,
       spec_text_code  gmd_specifications_b.text_code%TYPE,
       rslt_text_code  gmd_results.text_code%TYPE,
       result_value_char gmd_results.result_value_char%TYPE,
       result_value_num  gmd_results.result_value_num%TYPE,
       report_precision  NUMBER,
       coa_sort_order  NUMBER
      );

  TYPE t_coa_parameters IS RECORD
       (order_id            oe_order_headers_all.header_id%TYPE,
        --orgn_code           sy_orgn_mst.orgn_code%TYPE,  --INVCONV
        organization_id     mtl_parameters.organization_id%TYPE, --INVCONV
        cust_id             hz_cust_accounts.cust_account_id%TYPE,
        delivery_id         wsh_new_deliveries.delivery_id%TYPE,
        inventory_item_id   mtl_system_items_b_kfv.inventory_item_id%TYPE,  --INVCONV
        revision            mtl_item_revisions.revision%TYPE,  --Bug# 4662469
        --whse_code         ic_whse_mst.whse_code%TYPE, --INVCONV
        subinventory        mtl_secondary_inventories.secondary_inventory_name%TYPE, --INVCONV
        --location          ic_loct_mst.whse_code%TYPE, --INVCONV
        locator_id          NUMBER, --INVCONV
        --lot_id            ic_lots_mst.lot_id%TYPE, --INVCONV
        --lot_no            ic_lots_mst.lot_no%TYPE, --INVCONV
        lot_number          mtl_lot_numbers.lot_number%TYPE, --INVCONV
        org_id              oe_order_headers_all.org_id%TYPE,
        sampling_event_id   gmd_sampling_events.sampling_event_id%TYPE,
        spec_id             gmd_specifications_b.spec_id%TYPE,
	ship_to_site_id     hz_cust_site_uses_all.site_use_id%TYPE -- Bug# 5399406
       );

  TYPE MATCH_RESULT_LOT_REC_TYPE IS RECORD
  ( inventory_item_id          NUMBER             -- IN
   ,revision                   NUMBER  --Bug# 4662469
   --,lot_id         NUMBER                       -- IN  --INVCONV
   --,lot_no         VARCHAR2(32)                 -- IN  --INVCONV
   ,lot_number       mtl_lot_numbers.lot_number%TYPE --IN  --INVCONV
   --,whse_code      VARCHAR2(4)                  -- IN --INVCONV
   ,subinventory     mtl_secondary_inventories.secondary_inventory_name%TYPE --IN --INVCONV
   --,location       VARCHAR2(16)                 -- IN --INVCONV
   ,locator_id       NUMBER                       --IN --INVCONV
   ,cust_id          NUMBER                       -- IN
   ,called_from      VARCHAR2(4)                  -- IN
   ,sample_id        NUMBER                       -- OUT
   ,spec_match_type  VARCHAR2(1)                  -- OUT
   ,result_type      VARCHAR2(1)                  -- OUT
   ,event_spec_disp_id      NUMBER                -- OUT
   );

TYPE result_lot_match_tbl  IS TABLE OF MATCH_RESULT_LOT_REC_TYPE INDEX BY BINARY_INTEGER;



PROCEDURE populate_coa_data(
 p_api_version          IN               NUMBER
, p_init_msg_list       IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit              IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level    IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status       OUT NOCOPY       VARCHAR2
, x_msg_count           OUT NOCOPY       NUMBER
, x_msg_data            OUT NOCOPY       VARCHAR2
, param_rec             IN               t_coa_parameters);

FUNCTION get_text_for_range(p_test_id NUMBER,
                            p_value  NUMBER) RETURN VARCHAR2;

FUNCTION getprecision (p_value IN NUMBER,
                       p_report_precision IN NUMBER) return VARCHAR2;

PROCEDURE Log_Initialize;

PROCEDURE PrintLn(p_msg IN VARCHAR2);

PROCEDURE populate_hdr_text(tbl_hdr IN t_coa_hdr_rec,
                           x_return_status OUT NOCOPY  VARCHAR2); -- Bug # 4260445

END gmd_coa_data_om_new;

 

/
