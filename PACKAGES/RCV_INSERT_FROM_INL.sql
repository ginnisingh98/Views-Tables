--------------------------------------------------------
--  DDL for Package RCV_INSERT_FROM_INL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_INSERT_FROM_INL" AUTHID CURRENT_USER AS
/* $Header: RCVINSTS.pls 120.0.12010000.6 2013/10/22 08:20:36 kahe noship $ */

  CURSOR c_ship_lines(l_ship_header_id IN NUMBER) IS
    SELECT sl.ship_line_id,
           sl.ship_line_source_id,
           sl.inventory_item_id,
           sl.txn_qty,
           sl.txn_uom_code,
           sl.primary_qty,
           sl.primary_uom_code,
           sl.secondary_qty,        -- Bug 8911750
           sl.secondary_uom_code,   -- Bug 8911750
           sl.currency_code,
           sl.currency_conversion_type,
           sl.currency_conversion_date,
           sl.currency_conversion_rate,
           slg.party_id,
           slg.party_site_id,
           slg.src_type_code,
	     slg.ship_line_group_id,
           sh.organization_id,
           sh.location_id,
           sh.org_id,
           msi.description AS item_description,
           msi.segment1 AS item,
           sh.interface_source_code,
           sl.interface_source_table,
           sl.interface_source_line_id,
	    lc.unit_landed_cost,
     pl.VENDOR_PRODUCT_NUM --Added for bug # 17631658
    FROM   inl_ship_lines sl,
           inl_ship_line_groups slg,
           inl_ship_headers sh,
           inl_shipln_landed_costs_v lc,
           mtl_system_items msi,
           po_line_locations_all pll,  --Added for bug # 17631658
           po_lines_all pl   --Added for bug # 17631658
    WHERE  msi.inventory_item_id  = sl.inventory_item_id
    AND    msi.organization_id    = sh.organization_id
    AND    sl.ship_header_id      = slg.ship_header_id
    AND    sl.ship_line_group_id  = slg.ship_line_group_id
    AND    slg.ship_header_id     = sh.ship_header_id
    AND    lc.ship_line_id        = sl.ship_line_id
    AND    sh.ship_header_id      = l_ship_header_id
    AND    slg.src_type_code      = 'PO'
    AND    pll.po_line_id         = pl.po_line_id  --Added for bug # 17631658
    AND    pll.line_location_id   = sl.ship_line_source_id  --Added for bug # 17631658
    ORDER BY slg.ship_line_group_id;



  TYPE rti_rec_table IS TABLE OF c_ship_lines%ROWTYPE;

  PROCEDURE insert_rcv_tables (p_int_rec        IN rti_rec_table,
                               p_ship_header_id IN NUMBER);

END RCV_INSERT_FROM_INL;


/
