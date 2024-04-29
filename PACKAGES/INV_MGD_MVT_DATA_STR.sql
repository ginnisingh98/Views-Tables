--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_DATA_STR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_DATA_STR" AUTHID CURRENT_USER AS
-- $Header: INVDATSS.pls 120.2.12010000.2 2008/10/01 11:52:40 ajmittal ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVDATSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_MVT_DATA_STR                                       |
--|    Data Structure definitions:Includes record types, REF cursors      |
--|                                                                       |
--| HISTORY                                                               |
--|     03/20/00 pseshadr    Created                                      |
--|     06/07/00 ksaini      Added spec for Val_crsr cursor               |
--|     02/01/01 odaboval    Added spec for TRNI/TRNR, XFER cursors       |
--|                                     for OPSO and RECV cursors         |
--|     04/01/01 odaboval    Added 2 new rec-types.                       |
--|     11/22/02 vma         Removed defaulting parameters to             |
--|                          FND_API.G_MISS_NUM in Trans_Rec              |
--|     16/04/2007 Neelam Soni   Bug 5920143. Added support for Include   |
--|                              Establishments.                          |
--|     02-Aug-08  ajmittal     Bug 7165989 - Movement Statistics  RMA    |
--|                             Triangulation uptake. Modified the        |
--|				Movement_Transaction_Rec_Type record      |
--|				to include an additional attribue	  |

--+======================================================================*/

--===================
-- TYPES
--===================
-- This record type contains the attributes that are not in movement
-- statistics  table but these are used to derive some information
-- to populate mtl_movement_statistics for transaction type INVENTORY

TYPE Material_Transaction_Rec_Type IS RECORD
(
  transaction_type_id      mtl_material_transactions.transaction_type_id%TYPE
, transaction_action_id    mtl_material_transactions.transaction_action_id%TYPE
, transfer_organization_id
    mtl_material_transactions.transfer_organization_id%TYPE
, outside_processing_account
    mtl_material_transactions.outside_processing_account%TYPE
, vendor_lot_number        mtl_material_transactions.vendor_lot_number%TYPE
, acct_period_id           mtl_material_transactions.acct_period_id%TYPE
, transaction_date         mtl_material_transactions.transaction_id%TYPE
, last_update_date         DATE           := NULL
, last_updated_by          NUMBER         := NULL
, last_update_login        NUMBER         := NULL
);

-- This record type contains the attributes that are not in movement
-- statistics  table but these are used to derive some information
-- to populate mtl_movement_statistics for transaction type RECEIPT/PO

TYPE Receipt_Transaction_Rec_Type IS RECORD
(
  parent_transaction_id             rcv_transactions.parent_transaction_id%TYPE
, po_release_id                     rcv_transactions.po_release_id%TYPE
, to_organization_id                rcv_shipment_lines.to_organization_id%TYPE
, mrc_currency_conversion_date
    rcv_transactions.mrc_currency_conversion_date%TYPE
, mrc_currency_conversion_rate
    rcv_transactions.mrc_currency_conversion_rate%TYPE
, mrc_currency_conversion_type
    rcv_transactions.mrc_currency_conversion_type%TYPE
, mrc_po_unit_price                 NUMBER
, primary_unit_of_measure
    rcv_transactions.primary_unit_of_measure%TYPE
, uom_code                          rcv_transactions.uom_code%TYPE
, transaction_type                  rcv_transactions.transaction_type%TYPE
, source_document_code              rcv_transactions.source_document_code%TYPE
, last_update_date                  DATE           := NULL
, last_updated_by                   NUMBER         := NULL
, last_update_login                 NUMBER         := NULL
);


-- This record type contains the attributes that are not in movement
-- statistics  table but these are used to derive some information
-- to populate mtl_movement_statistics for transaction type SALES ORDER

TYPE Shipment_Transaction_Rec_Type IS RECORD
(
  org_id                      wsh_delivery_details.org_id%TYPE
, so_org_id                   oe_order_headers_all.org_id%TYPE
, shipped_quantity            oe_order_lines_all.shipped_quantity%TYPE
, last_update_date            DATE           := NULL
, last_updated_by             NUMBER         := NULL
, last_update_login           NUMBER         := NULL
, drop_ship_source_id         oe_drop_ship_sources.drop_ship_source_id%TYPE
, destination_org_id
    oe_drop_ship_sources.destination_organization_id%TYPE
, req_line_num                oe_order_lines_all.orig_sys_line_ref%TYPE
, req_num                     oe_order_headers_all.orig_sys_document_ref%TYPE
, order_source_id             oe_order_headers_all.order_source_id%TYPE
, mvt_stat_status             wsh_delivery_details.mvt_stat_status%TYPE
);


TYPE Movement_Transaction_Rec_Type IS RECORD
( movement_id                 mtl_movement_statistics.movement_id%TYPE
, organization_id             mtl_movement_statistics.organization_id%TYPE
, entity_org_id               mtl_movement_statistics.entity_org_id%TYPE
, movement_type               mtl_movement_statistics.movement_type%TYPE
, movement_status             mtl_movement_statistics.movement_status%TYPE
, transaction_date            mtl_movement_statistics.transaction_date%TYPE
, last_update_date            mtl_movement_statistics.last_update_date%TYPE
, last_updated_by             mtl_movement_statistics.last_updated_by%TYPE
, creation_date               mtl_movement_statistics.creation_date%TYPE
, created_by                  mtl_movement_statistics.created_by%TYPE
, last_update_login           mtl_movement_statistics.last_update_login%TYPE
, document_source_type        mtl_movement_statistics.document_source_type%TYPE
, creation_method             mtl_movement_statistics.creation_method%TYPE
, document_reference          mtl_movement_statistics.document_reference%TYPE
, document_line_reference
    mtl_movement_statistics.document_line_reference%TYPE
, document_unit_price         mtl_movement_statistics.document_unit_price%TYPE
, document_line_ext_value
    mtl_movement_statistics.document_line_ext_value%TYPE
, extended_amount             NUMBER
, receipt_reference           mtl_movement_statistics.receipt_reference%TYPE
, receipt_num                 rcv_shipment_headers.receipt_num%TYPE
, shipment_reference          mtl_movement_statistics.shipment_reference%TYPE
, shipment_line_reference
    mtl_movement_statistics.shipment_line_reference%TYPE
, pick_slip_reference         mtl_movement_statistics.pick_slip_reference%TYPE
, customer_name               mtl_movement_statistics.customer_name%TYPE
, customer_number             mtl_movement_statistics.customer_number%TYPE
, customer_location           mtl_movement_statistics.customer_location%TYPE
, transacting_from_org        mtl_movement_statistics.transacting_from_org%TYPE
, transacting_to_org          mtl_movement_statistics.transacting_to_org%TYPE
, transfer_organization_id
    mtl_material_transactions.transfer_organization_id%TYPE
, vendor_name                 mtl_movement_statistics.vendor_name%TYPE
, vendor_number               mtl_movement_statistics.vendor_number%TYPE
, vendor_site                 mtl_movement_statistics.vendor_site%TYPE
, bill_to_name                mtl_movement_statistics.bill_to_name%TYPE
, bill_to_number              mtl_movement_statistics.bill_to_number%TYPE
, bill_to_site                mtl_movement_statistics.bill_to_site%TYPE
, po_header_id                mtl_movement_statistics.po_header_id%TYPE
, po_line_id                  mtl_movement_statistics.po_line_id%TYPE
, po_line_location_id         mtl_movement_statistics.po_line_location_id%TYPE
, order_header_id             mtl_movement_statistics.order_header_id%TYPE
, order_line_id               mtl_movement_statistics.order_line_id%TYPE
, picking_line_id             mtl_movement_statistics.picking_line_id%TYPE
, shipment_header_id          mtl_movement_statistics.shipment_header_id%TYPE
, shipment_number             rcv_shipment_headers.shipment_num%TYPE
, shipment_line_id            mtl_movement_statistics.shipment_line_id%TYPE
, ship_to_customer_id         mtl_movement_statistics.ship_to_customer_id%TYPE
, ship_to_site_use_id         mtl_movement_statistics.ship_to_site_use_id%TYPE
, bill_to_customer_id         mtl_movement_statistics.bill_to_customer_id%TYPE
, bill_to_site_use_id         mtl_movement_statistics.bill_to_site_use_id%TYPE
, vendor_id                   mtl_movement_statistics.vendor_id%TYPE
, vendor_site_id              mtl_movement_statistics.vendor_site_id%TYPE
, from_organization_id        mtl_movement_statistics.from_organization_id%TYPE
, to_organization_id          mtl_movement_statistics.to_organization_id%TYPE
, parent_movement_id          mtl_movement_statistics.parent_movement_id%TYPE
, inventory_item_id           mtl_movement_statistics.inventory_item_id%TYPE
, item_description            mtl_movement_statistics.item_description%TYPE
, item_cost                   mtl_movement_statistics.item_cost%TYPE
, transaction_quantity        mtl_movement_statistics.transaction_quantity%TYPE
, transaction_uom_code        mtl_movement_statistics.transaction_uom_code%TYPE
, primary_quantity            mtl_movement_statistics.primary_quantity%TYPE
, primary_uom_code            mtl_movement_statistics.transaction_uom_code%TYPE
, shipped_quantity            wsh_delivery_details.shipped_quantity%TYPE
, invoice_batch_id            mtl_movement_statistics.invoice_batch_id%TYPE
, invoice_id                  mtl_movement_statistics.invoice_id%TYPE
, customer_trx_line_id        mtl_movement_statistics.customer_trx_line_id%TYPE
, invoice_batch_reference
    mtl_movement_statistics.invoice_batch_reference%TYPE
, invoice_reference           mtl_movement_statistics.invoice_reference%TYPE
, invoice_line_reference
    mtl_movement_statistics.invoice_line_reference%TYPE
, invoice_date_reference
    mtl_movement_statistics.invoice_date_reference%TYPE
, invoice_quantity            mtl_movement_statistics.invoice_quantity%TYPE
, invoice_unit_price          mtl_movement_statistics.invoice_unit_price%TYPE
, invoice_line_ext_value
    mtl_movement_statistics.invoice_line_ext_value%TYPE
, outside_code                mtl_movement_statistics.outside_code%TYPE
, outside_ext_value           mtl_movement_statistics.outside_ext_value%TYPE
, outside_unit_price          mtl_movement_statistics.outside_unit_price%TYPE
, currency_code               mtl_movement_statistics.currency_code%TYPE
, gl_currency_code            VARCHAR2(15)
, currency_conversion_rate
    mtl_movement_statistics.currency_conversion_rate%TYPE
, currency_conversion_type
    mtl_movement_statistics.currency_conversion_type%TYPE
, currency_conversion_date
    mtl_movement_statistics.currency_conversion_date%TYPE
, period_name                 mtl_movement_statistics.period_name%TYPE
, report_reference            mtl_movement_statistics.report_reference%TYPE
, report_date                 mtl_movement_statistics.report_date%TYPE
, category_id                 mtl_movement_statistics.category_id%TYPE
, weight_method               mtl_movement_statistics.weight_method%TYPE
, unit_weight                 mtl_movement_statistics.unit_weight%TYPE
, total_weight                mtl_movement_statistics.total_weight%TYPE
, transaction_nature          mtl_movement_statistics.transaction_nature%TYPE
, delivery_terms              mtl_movement_statistics.delivery_terms%TYPE
, transport_mode              mtl_movement_statistics.transport_mode%TYPE
, alternate_quantity          mtl_movement_statistics.alternate_quantity%TYPE
, alternate_uom_code          mtl_movement_statistics.alternate_uom_code%TYPE
, dispatch_territory_code
    mtl_movement_statistics.dispatch_territory_code%TYPE
, destination_territory_code
    mtl_movement_statistics.destination_territory_code%TYPE
, origin_territory_code
    mtl_movement_statistics.origin_territory_code%TYPE
, origin_territory_eu_code
    mtl_movement_statistics.origin_territory_eu_code%TYPE
, dispatch_territory_eu_code
    mtl_movement_statistics.dispatch_territory_eu_code%TYPE
, destination_territory_eu_code
    mtl_movement_statistics.destination_territory_eu_code%TYPE
, triangulation_country_eu_code
    mtl_movement_statistics.triangulation_country_eu_code%TYPE
, stat_method                 mtl_movement_statistics.stat_method%TYPE
, stat_adj_percent            mtl_movement_statistics.stat_adj_percent%TYPE
, stat_adj_amount             mtl_movement_statistics.stat_adj_amount%TYPE
, stat_ext_value              mtl_movement_statistics.stat_ext_value%TYPE
, area                        mtl_movement_statistics.area%TYPE
, port                        mtl_movement_statistics.port%TYPE
, stat_type                   mtl_movement_statistics.stat_type%TYPE
, statistical_procedure_code
    mtl_movement_statistics.statistical_procedure_code%TYPE
, comments                    mtl_movement_statistics.comments%TYPE
, attribute_category          mtl_movement_statistics.attribute_category%TYPE
, attribute1                  mtl_movement_statistics.attribute1%TYPE
, attribute2                  mtl_movement_statistics.attribute2%TYPE
, attribute3                  mtl_movement_statistics.attribute3%TYPE
, attribute4                  mtl_movement_statistics.attribute4%TYPE
, attribute5                  mtl_movement_statistics.attribute5%TYPE
, attribute6                  mtl_movement_statistics.attribute6%TYPE
, attribute7                  mtl_movement_statistics.attribute7%TYPE
, attribute8                  mtl_movement_statistics.attribute8%TYPE
, attribute9                  mtl_movement_statistics.attribute9%TYPE
, attribute10                 mtl_movement_statistics.attribute10%TYPE
, attribute11                 mtl_movement_statistics.attribute11%TYPE
, attribute12                 mtl_movement_statistics.attribute12%TYPE
, attribute13                 mtl_movement_statistics.attribute13%TYPE
, attribute14                 mtl_movement_statistics.attribute14%TYPE
, attribute15                 mtl_movement_statistics.attribute15%TYPE
, commodity_code              mtl_movement_statistics.commodity_code%TYPE
, commodity_description
    mtl_movement_statistics.commodity_description%TYPE
, requisition_header_id
    mtl_movement_statistics.requisition_header_id%TYPE
, requisition_line_id         mtl_movement_statistics.requisition_line_id%TYPE
, picking_line_detail_id
    mtl_movement_statistics.picking_line_detail_id%TYPE
, usage_type                  mtl_movement_statistics.usage_type%TYPE
, zone_code                   mtl_movement_statistics.zone_code%TYPE
, edi_sent_flag               mtl_movement_statistics.edi_sent_flag%TYPE
, movement_amount             mtl_movement_statistics.movement_amount%TYPE
, order_number                oe_order_headers_all.order_number%TYPE
, line_number                 oe_order_lines_all.line_number%TYPE
, triangulation_country_code
     mtl_movement_statistics.triangulation_country_code%TYPE
, csa_code                    mtl_movement_statistics.csa_code%TYPE
, taric_code                  mtl_movement_statistics.taric_code%TYPE
, preference_code             mtl_movement_statistics.preference_code%TYPE
, oil_reference_code          mtl_movement_statistics.oil_reference_code%TYPE
, container_type_code         mtl_movement_statistics.container_type_code%TYPE
, flow_indicator_code         mtl_movement_statistics.flow_indicator_code%TYPE
, affiliation_reference_code
    mtl_movement_statistics.affiliation_reference_code%TYPE
, set_of_books_period         mtl_movement_statistics.set_of_books_period%TYPE
, distribution_line_number
    mtl_movement_statistics.distribution_line_number%TYPE
, rcv_transaction_id          mtl_movement_statistics.rcv_transaction_id%TYPE
, mtl_transaction_id          mtl_movement_statistics.mtl_transaction_id%TYPE
, total_weight_uom_code       mtl_movement_statistics.total_weight_uom_code%TYPE
, ship_to_name                mtl_movement_statistics.ship_to_name%TYPE
, ship_to_number              mtl_movement_statistics.ship_to_number%TYPE
, ship_to_site                mtl_movement_statistics.ship_to_site%TYPE
, financial_document_flag
    mtl_movement_statistics.financial_document_flag%TYPE
, edi_transaction_reference
    mtl_movement_statistics.edi_transaction_reference%TYPE
, edi_transaction_date
    mtl_movement_statistics.edi_transaction_date%TYPE
, esl_drop_shipment_code   mtl_movement_statistics.esl_drop_shipment_code%TYPE
, customer_vat_number      mtl_movement_statistics.customer_vat_number%TYPE
, transaction_type_id      mtl_material_transactions.transaction_type_id%TYPE
, transaction_action_id    mtl_material_transactions.transaction_action_id%TYPE
--, opm_trans_id             NUMBER
, org_id                   oe_order_headers_all.org_id%TYPE
, release_id               rcv_transactions.po_release_id%TYPE
, type_lookup_code         po_headers_all.type_lookup_code%TYPE
, reference_date           DATE
, consigned_flag           rcv_transactions.consigned_flag%TYPE
, sold_from_org_id         oe_order_headers_all.sold_from_org_id%TYPE -- 7165989
);

--Bug: 5920143. New column include_establishments has beed added in
-- record definition.
TYPE Movement_Stat_Usages_Rec_Type IS RECORD
( legal_entity_id    mtl_stat_type_usages.legal_entity_id%TYPE
, zone_code          mtl_stat_type_usages.zone_code%TYPE
, usage_type         mtl_stat_type_usages.usage_type%TYPE
, stat_type          mtl_stat_type_usages.stat_type%TYPE
, start_date         DATE
, end_date           DATE
, conversion_option  mtl_stat_type_usages.conversion_option%TYPE
, conversion_type    mtl_stat_type_usages.conversion_type%TYPE
, category_set_id    mtl_stat_type_usages.category_set_id%TYPE
, weight_uom_code    mtl_stat_type_usages.weight_uom_code%TYPE
, gl_currency_code   VARCHAR2(15)
, gl_set_of_books_id NUMBER
, gl_end_date        DATE
, gl_period_name     VARCHAR2(15)
, start_period_name  mtl_stat_type_usages.start_period_name%TYPE
, end_period_name    mtl_stat_type_usages.end_period_name%TYPE
, period_set_name    mtl_stat_type_usages.period_set_name%TYPE
, period_type        mtl_stat_type_usages.period_type%TYPE
, attribute_rule_set_code
                     mtl_stat_type_usages.attribute_rule_set_code%TYPE
, alt_uom_rule_set_code
                     mtl_stat_type_usages.alt_uom_rule_set_code%TYPE
, triangulation_mode mtl_stat_type_usages.triangulation_mode%TYPE
, reference_period_rule mtl_stat_type_usages.reference_period_rule%TYPE
, pending_invoice_days  mtl_stat_type_usages.pending_invoice_days%TYPE
, prior_invoice_days    mtl_stat_type_usages.prior_invoice_days%TYPE
, returns_processing    mtl_stat_type_usages.returns_processing%TYPE
, kit_method            mtl_stat_type_usages.kit_method%TYPE
, include_establishments            mtl_stat_type_usages.include_establishments%TYPE
);


-- Declare the REF Cursor

TYPE invCurTyp  IS REF CURSOR;
TYPE invidCurTyp  IS REF CURSOR;
TYPE soCurTyp   IS REF CURSOR;
TYPE poCurTyp   IS REF CURSOR;
TYPE rtvCurTyp  IS REF CURSOR;
TYPE valCurTyp  IS REF CURSOR;
stat_type_usages_rec Movement_stat_usages_rec_type;
TYPE setupCurTyp IS REF CURSOR;

TYPE Trans_Rec IS RECORD
( movement_id            NUMBER
, picking_line_detail_id NUMBER
, rcv_transaction_id     NUMBER
, mtl_transaction_id     NUMBER
);

TYPE Trans_List IS TABLE OF Trans_Rec
INDEX BY BINARY_INTEGER ;




--========================================================================
--
-- COMMENT   :  PL/SQL Table type definition. This table reference
--              will be used to
---             populate and print the exception messages
--              Defined by rajkrish
--===========================================================================

  TYPE EXCP_REC IS RECORD
  (  excp_col_name varchar2(40)
   , excp_message_cd number) ;

  TYPE EXCP_LIST IS TABLE OF EXCP_REC
       INDEX BY BINARY_INTEGER ;



END INV_MGD_MVT_DATA_STR;

/
