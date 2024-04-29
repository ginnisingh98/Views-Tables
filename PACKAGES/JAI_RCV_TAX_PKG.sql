--------------------------------------------------------
--  DDL for Package JAI_RCV_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_tax.pls 120.3.12010000.3 2009/08/07 11:41:51 nprashar ship $ */
  PROCEDURE default_taxes_onto_line
    (
        p_transaction_id                NUMBER,
        p_parent_transaction_id         NUMBER,
        p_shipment_header_id            NUMBER,
        p_shipment_line_id              NUMBER,
        p_organization_id               NUMBER,
        p_requisition_line_id           NUMBER,
        p_qty_received                  NUMBER,
        p_primary_quantity              NUMBER,
        p_line_location_id              NUMBER,
        p_transaction_type              VARCHAR2,
        p_source_document_code          VARCHAR2,
        p_destination_type_code         VARCHAR2,
        p_subinventory                  VARCHAR2,
        p_vendor_id                     NUMBER,
        p_vendor_site_id                NUMBER,
        p_po_header_id                  NUMBER,
        p_po_line_id                    NUMBER,
        p_location_id                   NUMBER,
        p_transaction_date              DATE,
        p_uom_code                      VARCHAR2,
        --Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute1                    VARCHAR2,
        ---p_attribute2                    DATE,
        --p_attribute3                    VARCHAR2,
        --p_attribute4                    VARCHAR2,
        p_attribute15                   VARCHAR2,
        p_currency_code                 VARCHAR2,
        p_currency_conversion_type      VARCHAR2,
        p_currency_conversion_date      DATE,
        p_currency_conversion_rate      NUMBER,
        p_creation_date                 DATE,
        p_created_by                    NUMBER,
        p_last_update_date              DATE,
        p_last_updated_by               NUMBER,
        p_last_update_login             NUMBER,
        p_unit_of_measure               VARCHAR2,
        p_po_distribution_id            NUMBER,
        p_oe_order_header_id            NUMBER,
        p_oe_order_line_id              NUMBER,
        p_routing_header_id             NUMBER,
        p_interface_source_code         VARCHAR2,
        p_interface_transaction_id      VARCHAR2,
        p_allow_tax_change_hook         VARCHAR2
        --Reverted the change in R12 p_group_id                         IN    NUMBER DEFAULT NULL /*Added by nprashar for bug # 8566481 */
    );
END jai_rcv_tax_pkg;

/
